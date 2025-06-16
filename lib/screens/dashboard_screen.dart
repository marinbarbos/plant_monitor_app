import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: const MicroGardenAppBar(
        titleWidget: const Text(
          'DASHBOARD',
          style: TextStyle(color: Colors.grey),
        ),
        showBackButton: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // --- Sensor Cards ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _statusTile(
                  label: 'Temperatura: 23 °C',
                  status: 'Ideal',
                  backgroundColor: Colors.redAccent,
                  statusColor: Colors.white,
                ),
                _statusTile(
                  label: 'Luminosidade: Claro',
                  status: 'Diminuir',
                  backgroundColor: Colors.yellow[700]!,
                  statusColor: Colors.blue,
                ),
                _statusTile(
                  label: 'Humidade do Solo: 55%',
                  status: 'Aumentar',
                  backgroundColor: Colors.amber[400]!,
                  statusColor: Colors.indigo,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // --- Emoji and Plant Display ---
          Column(
            children: [
              const Text(
                '😐', // You can change to 😐, ☹ depending on status logic
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/images/sprout.png', height: 80),
              const SizedBox(height: 10),
              Container(height: 20, width: 100, color: Colors.grey[700]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusTile({
    required String label,
    required String status,
    required Color backgroundColor,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          Text(status, style: TextStyle(fontSize: 16, color: statusColor)),
        ],
      ),
    );
  }
}
