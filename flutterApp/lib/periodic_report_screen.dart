import 'dart:math';
import 'package:power_monitor/main.dart'; // Ensure ChartData is defined in main.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Add this for charts

class PeriodicReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Periodic Report")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportGraph(title: "Weekly Current Consumption (A)", data: generateData(7), isPower: false),
            ReportGraph(title: "Weekly Power Consumption (kW)", data: generateData(7), isPower: true),

            ReportGraph(title: "Monthly Current Consumption (A)", data: generateData(30), isPower: false),
            ReportGraph(title: "Monthly Power Consumption (kW)", data: generateData(30), isPower: true),

            ReportGraph(title: "Yearly Current Consumption (A)", data: generateData(12), isPower: false),
            ReportGraph(title: "Yearly Power Consumption (kW)", data: generateData(12), isPower: true),
          ],
        ),
      ),
    );
  }
}

class ReportGraph extends StatelessWidget {
  final String title;
  final List<ChartData> data;
  final bool isPower; // To distinguish between current and power graphs

  const ReportGraph({required this.title, required this.data, required this.isPower});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SfCartesianChart(
          title: ChartTitle(text: title),
          primaryXAxis: CategoryAxis(),
          series: <CartesianSeries<ChartData, String>>[
            LineSeries<ChartData, String>(
              dataSource: data,
              xValueMapper: (ChartData point, _) => point.time,
              yValueMapper: (ChartData point, _) => isPower ? point.power : point.current, // Use correct metric
              markerSettings: const MarkerSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to generate random ChartData
List<ChartData> generateData(int count) {
  return List.generate(count, (index) {
    double randomCurrent = 50 + Random().nextDouble() * 50;
    double randomPower = 500 + Random().nextDouble() * 500;
    return ChartData("Day ${index + 1}", 0, randomCurrent, randomPower);
  });
}
