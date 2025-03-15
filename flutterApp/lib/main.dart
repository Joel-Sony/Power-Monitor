import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:power_monitor/alerts_screen.dart';
import 'package:power_monitor/periodic_report_screen.dart';
import 'package:power_monitor/download_reports_screen.dart';


void main() {
  runApp(const PowerMonitorApp());
}

class PowerMonitorApp extends StatelessWidget {
  const PowerMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: DashboardScreen(),
    );
  }
}

Set<String> alerts = {}; // Avoid duplicates
List<ChartData> historicalData = [];

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Power Monitoring Dashboard"),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PeriodicReportScreen())),
            child: const Text("Periodic Report", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlertsScreen())),
            child: const Text("Alerts", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DownloadReportsScreen()),
            ),
            child: const Text("Download Report", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double voltageSize = screenWidth * 0.35;
          double smallDialSize = screenWidth * 0.25;

          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DialWidget(title: "Current", minValue: 0, maxValue: 300, size: smallDialSize),
                DialWidget(title: "Voltage", minValue: 50, maxValue: 300, size: voltageSize),
                DialWidget(title: "Power", minValue: 0, maxValue: 10000, size: smallDialSize),
              ],
            ),
          );
        },
      ),
    );
  }

  static Future<void> _downloadReport() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Power Monitoring Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ["Time", "Voltage (V)", "Current (A)", "Power (W)"],
                data: historicalData.map((e) => [e.time, e.voltage.toStringAsFixed(2), e.current.toStringAsFixed(2), e.power.toStringAsFixed(2)]).toList(),
              ),
            ],
          );
        },
      ),
    );
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/Power_Report.pdf");
    await file.writeAsBytes(await pdf.save());
    print("Report saved to: ${file.path}");
  }
}

class DialWidget extends StatefulWidget {
  final String title;
  final double minValue;
  final double maxValue;
  final double size;

  const DialWidget({
    required this.title,
    required this.minValue,
    required this.maxValue,
    this.size = 180,
  });

  @override
  _DialWidgetState createState() => _DialWidgetState();
}

class _DialWidgetState extends State<DialWidget> {
  double currentValue = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        currentValue = widget.minValue + Random().nextDouble() * (widget.maxValue - widget.minValue);
        _updateHistoricalData();
        _checkAlerts();
      });
    });
  }

  void _updateHistoricalData() {
    String currentTime = "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
    if (historicalData.isEmpty || historicalData.last.time != currentTime) {
      historicalData.add(ChartData(currentTime, 0, 0, 0));
    }
    if (widget.title == "Voltage") {
      historicalData.last.voltage = currentValue;
    } else if (widget.title == "Current") {
      historicalData.last.current = currentValue;
    } else if (widget.title == "Power") {
      historicalData.last.power = currentValue;
    }
  }

  void _checkAlerts() {
    if (widget.title == "Current" && currentValue > 100) {
      alerts.add("⚠ High Current Alert: ${currentValue.toStringAsFixed(1)}A");
    }
    if (widget.title == "Voltage" && currentValue > 270) {
      alerts.add("⚠ High Voltage Alert: ${currentValue.toStringAsFixed(1)}V");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          SizedBox(
            height: widget.size,
            width: widget.size,
            child: gauges.SfRadialGauge(
              enableLoadingAnimation: true,
              animationDuration: 1200,
              axes: [
                gauges.RadialAxis(
                  minimum: widget.minValue,
                  maximum: widget.maxValue,
                  axisLineStyle: const gauges.AxisLineStyle(
                    thickness: 15,
                    cornerStyle: gauges.CornerStyle.bothCurve,
                    gradient: SweepGradient(colors: [Colors.green, Colors.yellow, Colors.red], stops: [0.4, 0.75, 1]),
                  ),
                  pointers: [
                    gauges.NeedlePointer(value: currentValue, enableAnimation: true, needleColor: Colors.white),
                  ],
                  annotations: [
                    gauges.GaugeAnnotation(
                      widget: Text("${currentValue.toStringAsFixed(1)} ${widget.title == "Voltage" ? "V" : widget.title == "Current" ? "A" : "W"}",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      positionFactor: 0.8,
                      angle: 90,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String time;
  double voltage;
  double current;
  double power;

  ChartData(this.time, this.voltage, this.current, this.power);
}