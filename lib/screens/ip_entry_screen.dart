import 'package:flutter/material.dart';
import 'package:plant_monitor_1/screens/dashboard_screen.dart';
import 'profile_screen.dart';

class IPInputPage extends StatefulWidget {
  const IPInputPage({super.key});

  @override
  State<IPInputPage> createState() => _IPInputPageState();
}

class _IPInputPageState extends State<IPInputPage> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  final RegExp _ipRegex = RegExp(
    r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
  );

  void _validateAndProceed() {
    if (_ipRegex.hasMatch(_controller.text.trim())) {
      setState(() => _errorText = null);
      _simulateConnection(_controller.text.trim());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else {
      setState(() => _errorText = 'Endereço IP inválido');
    }
  }

  void _simulateConnection(String ip) {
    // TODO: Replace this with actual Arduino connection logic later
    debugPrint("Connecting to Arduino at $ip...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Por favor digite o endereço IP mostrado na tela do dispositivo:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ex: 192.168.0.1',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E2B5F),
              ),
              onPressed: _validateAndProceed,
              child: const Text('Confirmar'),
            ),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E2B5F),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
                child: const Text('Pular'),
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset('assets/images/sprout.png', height: 50),
            ),
          ],
        ),
      ),
    );
  }
}
