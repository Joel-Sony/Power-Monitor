import 'package:flutter/material.dart';
import 'package:power_monitor/main.dart'; // Ensure alerts list is imported

class AlertsScreen extends StatefulWidget {
  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alerts")),
      body: alerts.isEmpty
          ? const Center(
              child: Text("No alerts.", style: TextStyle(fontSize: 18, color: Colors.white)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(alerts.elementAt(index)), // Ensure unique key for Set
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    setState(() {
                      alerts.remove(alerts.elementAt(index));
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Alert dismissed"), duration: Duration(seconds: 1)),
                    );
                  },
                  child: Card(
                    color: Colors.red[900],
                    child: ListTile(
                      title: Text(alerts.elementAt(index), style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            alerts.remove(alerts.elementAt(index));
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}