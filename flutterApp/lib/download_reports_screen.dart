import 'package:flutter/material.dart';

class DownloadReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Download Reports")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("⚡ ENERGY USAGE REPORT ⚡", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildSection("📅 Period:", "Mar 1 - Mar 15, 2025"),
              _buildSection("📌 Device:", "Main Power Monitor"),
              _buildSection("🕒 Generated:", "Mar 15, 2025"),
              const SizedBox(height: 10),
              const Divider(),
              _buildSection("🔹 Total Energy:", "150.2 kWh"),
              _buildSection("🔹 Peak Power:", "1200 W"),
              _buildSection("🔹 Peak Voltage:", "245 V"),
              _buildSection("🔹 Peak Current:", "5.2 A"),
              _buildSection("🔹 Avg Power:", "800 W"),
              _buildSection("💰 Estimated Cost:", "\$22.53"),
              const SizedBox(height: 10),
              const Divider(),
              const Text("📊 Recent Usage (Last 5 Days)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildUsageRow("03-11", "9.8 kWh", "980 W"),
              _buildUsageRow("03-12", "10.2 kWh", "1000 W"),
              _buildUsageRow("03-13", "8.5 kWh", "950 W"),
              _buildUsageRow("03-14", "12.1 kWh", "1100 W"),
              _buildUsageRow("03-15", "9.5 kWh", "970 W"),
              const SizedBox(height: 10),
              const Divider(),
              const Text("🚨 Alerts & Violations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildAlert("03-05", "14:32", "Overvoltage: 250V (⚠️ 245V)"),
              _buildAlert("03-07", "19:15", "Overcurrent: 6.0A (⚠️ 5.5A)"),
              _buildAlert("03-12", "22:05", "High Power: 1250W (⚠️ 1200W)"),
              const SizedBox(height: 10),
              const Divider(),
              _buildSection("💲 Tariff Rate:", "\$0.15/kWh"),
              _buildSection("💲 Total Cost:", "\$22.53"),
              _buildSection("💲 Projected Bill:", "\$45.20"),
              const SizedBox(height: 10),
              const Divider(),
              const Text("✅ Recommendations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildBulletPoint("✔ Reduce peak load to lower cost"),
              _buildBulletPoint("✔ Shift heavy usage to off-peak hours"),
              _buildBulletPoint("✔ Investigate voltage spikes for safety"),
              const SizedBox(height: 10),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () {}, child: const Text("📂 Export PDF")),
                  ElevatedButton(onPressed: () {}, child: const Text("📂 Export CSV")),
                  ElevatedButton(onPressed: () {}, child: const Text("📂 Export Excel")),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("📩 Auto Reports: ", style: TextStyle(fontSize: 16)),
                  Switch(value: true, onChanged: (bool value) {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildUsageRow(String date, String energy, String peak) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date),
          Text("$energy | Peak: $peak"),
        ],
      ),
    );
  }

  Widget _buildAlert(String date, String time, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$date | $time"),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          const Text("• ", style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}