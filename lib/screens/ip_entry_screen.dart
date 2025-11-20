import 'package:flutter/material.dart';
import '../services/esp32_service.dart';
import '../services/achievement_tracker.dart';
import '../widgets/achievement_widget.dart';
import 'dashboard_screen.dart';

class IPInputPage extends StatefulWidget {
  const IPInputPage({super.key});

  @override
  State<IPInputPage> createState() => _IPInputPageState();
}

class _IPInputPageState extends State<IPInputPage>
    with AchievementDialogMixin {
  final TextEditingController _controller = TextEditingController();
  final ESP32Service _esp32Service = ESP32Service();
  final AchievementTracker _tracker = AchievementTracker();
  String? _errorText;
  bool _isConnecting = false;

  final RegExp _ipRegex = RegExp(
    r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
  );

  @override
  void initState() {
    super.initState();
    _loadSavedIP();
  }

  Future<void> _loadSavedIP() async {
    final savedIP = await _esp32Service.loadIPAddress();
    if (savedIP != null && mounted) {
      setState(() {
        _controller.text = savedIP;
      });
    }
  }

  Future<void> _validateAndProceed() async {
    final ipAddress = _controller.text.trim();

    if (!_ipRegex.hasMatch(ipAddress)) {
      setState(() => _errorText = 'Endereço IP inválido');
      return;
    }

    setState(() {
      _errorText = null;
      _isConnecting = true;
    });

    // Save IP to SharedPreferences
    await _esp32Service.setIPAddress(ipAddress);

    // Test connection
    final isConnected = await _esp32Service.testConnection();

    if (!mounted) return;

    if (isConnected) {
      // Track first connection achievement
      final leveledUp = await _tracker.onFirstConnection();

      if (leveledUp && mounted) {
        await showLevelUpDialog();
      }

      // Connection successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conectado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else {
      // Connection failed
      setState(() {
        _errorText = 'Não foi possível conectar ao ESP32';
        _isConnecting = false;
      });

      // Show dialog with options
      _showConnectionFailedDialog(ipAddress);
    }
  }

  void _showConnectionFailedDialog(String ipAddress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Falha na Conexão',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Não foi possível conectar ao ESP32 em $ipAddress.\n\n'
          'Verifique se:\n'
          '• O dispositivo está ligado\n'
          '• Você está conectado à rede Wi-Fi do ESP32\n'
          '• O endereço IP está correto',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tentar Novamente'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _continueAnyway(ipAddress);
            },
            child: const Text('Continuar Mesmo Assim'),
          ),
        ],
      ),
    );
  }

  void _continueAnyway(String ipAddress) async {
    // IP is already saved from _validateAndProceed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
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
            // Instructions
            const Icon(
              Icons.wifi,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),
            const Text(
              'Conectar ao ESP32',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Digite o endereço IP mostrado na tela do dispositivo:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // IP Input Field
            TextField(
              controller: _controller,
              enabled: !_isConnecting,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ex: 192.168.4.1',
                errorText: _errorText,
                prefixIcon: const Icon(Icons.router),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _errorText = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              onSubmitted: (_) => _validateAndProceed(),
            ),
            const SizedBox(height: 24),

            // Connect Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isConnecting ? null : _validateAndProceed,
                child: _isConnecting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Conectar',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Help Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[900]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[700]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[300], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Certifique-se de estar conectado à rede Wi-Fi do ESP32',
                      style: TextStyle(color: Colors.blue[100], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Skip Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                onPressed: _isConnecting
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardPage(),
                          ),
                        );
                      },
                icon: const Icon(Icons.skip_next),
                label: const Text('Pular por enquanto'),
              ),
            ),
            const Spacer(),

            // Bottom decoration
            Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                'assets/images/sprout.png',
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
