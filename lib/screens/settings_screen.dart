import 'package:flutter/material.dart';
import 'ip_entry_screen.dart';
import '../widgets/navbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MicroGardenAppBar(
        titleWidget: Text('SETTINGS', style: TextStyle(color: Colors.grey)),
        showBackButton: true,
      ),
      backgroundColor: const Color(0xFF2C2C2C),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D4A84),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IPInputPage()),
                );
              },
              child: const Text(
                'Reconfigurar IP',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const Spacer(),
            const Text(
              'Aplicativo V0.0.1',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Marina Barbosa\nmb.americo@unesp.br',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
