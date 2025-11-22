import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/achievement_widget.dart';
import '../services/esp32_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> 
    with AchievementNotificationMixin {
  final ESP32Service _esp32Service = ESP32Service();
  PlantData? _plantData;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _trackDailyCheckIn();
  }

  void _initializeService() {
    // Set up callbacks
    _esp32Service.onDataUpdate = (data) {
      if (mounted) {
        setState(() {
          _plantData = data;
          _isLoading = false;
          _errorMessage = null;
          _lastUpdate = DateTime.now();
        });
        
        // Track plant health achievements
        _trackPlantHealth(data);
      }
    };

    _esp32Service.onError = (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
      }
    };

    // Start periodic updates every 2 minutes
    _esp32Service.startPeriodicUpdates(
      interval: const Duration(minutes: 2),
    );
  }
  
  /// Track daily check-in achievement
  Future<void> _trackDailyCheckIn() async {
    await trackDailyCheckIn();
  }
  
  /// Track plant health related achievements
  Future<void> _trackPlantHealth(PlantData data) async {
    final healthScore = data.getHealthScore();
    
    // Track overall health
    await trackHealthUpdate(healthScore);
    
    // Track temperature if ideal
    if (data.getTemperatureStatus().toLowerCase() == 'ideal') {
      await trackIdealTemperature();
    }
    
    // Track moisture if ideal
    if (data.getSoilMoistureStatus().toLowerCase() == 'ideal') {
      await trackIdealMoisture();
    }
    
    // Track light if ideal (assuming light is ideal when in optimal range)
    if (data.getLightStatus().toLowerCase() == 'ideal') {
      await trackLightAdjustment();
    }
  }

  @override
  void dispose() {
    _esp32Service.stopPeriodicUpdates();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = await _esp32Service.fetchSensorData();
    if (mounted) {
      setState(() {
        if (data != null) {
          _plantData = data;
          _lastUpdate = DateTime.now();
          
          // Track achievements on manual refresh too
          _trackPlantHealth(data);
        } else {
          _errorMessage = 'Falha ao atualizar dados';
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: const MicroGardenAppBar(
        titleWidget: Text('DASHBOARD', style: TextStyle(color: Colors.grey)),
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Connection Status
                _buildConnectionStatus(),
                const SizedBox(height: 12),

                // Error Message
                if (_errorMessage != null) _buildErrorMessage(),

                // Loading Indicator
                if (_isLoading && _plantData == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_plantData != null) ...[
                  // Sensor Cards
                  _buildSensorCards(),
                  const SizedBox(height: 24),

                  // Plant Status Display
                  _buildPlantStatusDisplay(),
                ] else
                  _buildNoDataMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final ip = _esp32Service.ipAddress;
    final isConnected = _plantData != null && _errorMessage == null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green[900] : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.error_outline,
            color: isConnected ? Colors.greenAccent : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Conectado' : 'Desconectado',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ip != null)
                  Text(
                    'ESP32: $ip',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                if (_lastUpdate != null)
                  Text(
                    'Última atualização: ${_formatTime(_lastUpdate!)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _refreshData,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum dado disponível',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure o endereço IP nas configurações',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: const Text('Ir para Configurações'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCards() {
    return Column(
      children: [
        _statusTile(
          label: 'Temperatura: ${_plantData!.temperature.toStringAsFixed(1)} °C',
          status: _getStatusText(_plantData!.getTemperatureStatus()),
          backgroundColor: Colors.redAccent,
          statusColor: _getStatusColor(_plantData!.getTemperatureStatus()),
          icon: Icons.thermostat,
        ),
        _statusTile(
          label: 'Luminosidade: ${_plantData!.getLightDescription()}',
          status: _getStatusText(_plantData!.getLightStatus()),
          backgroundColor: Colors.yellow[700]!,
          statusColor: _getStatusColor(_plantData!.getLightStatus()),
          icon: Icons.wb_sunny,
        ),
        _statusTile(
          label:
              'Humidade do Solo: ${_plantData!.soilMoisture.toStringAsFixed(1)}%',
          status: _getStatusText(_plantData!.getSoilMoistureStatus()),
          backgroundColor: Colors.amber[400]!,
          statusColor: _getStatusColor(_plantData!.getSoilMoistureStatus()),
          icon: Icons.water_drop,
        ),
      ],
    );
  }

  Widget _buildPlantStatusDisplay() {
    final status = _plantData!.getPlantStatus();
    final healthScore = _plantData!.getHealthScore();

    return Column(
      children: [
        // Health Score
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'Saúde da Planta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$healthScore',
                    style: TextStyle(
                      color: status.statusColor,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '/100',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: healthScore / 100,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation<Color>(status.statusColor),
                minHeight: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Emoji Status
        Text(
          status.emoji,
          style: const TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 12),

        // Status Name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: status.statusColor.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: status.statusColor, width: 2),
          ),
          child: Text(
            status.name,
            style: TextStyle(
              color: status.statusColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Status Description
        Text(
          status.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Plant Image
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Try to load status-specific image, fallback to sprout
              Image.asset(
                status.imagePath,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/sprout.png',
                    height: 120,
                  );
                },
              ),
              const SizedBox(height: 16),
              // Pot representation
              Container(
                height: 30,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.brown[700],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusTile({
    required String label,
    required String status,
    required Color backgroundColor,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 16,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'ideal':
        return 'Ideal';
      case 'aumentar':
        return 'Aumentar';
      case 'diminuir':
        return 'Diminuir';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ideal':
        return Colors.greenAccent;
      case 'aumentar':
        return Colors.blue;
      case 'diminuir':
        return Colors.deepOrangeAccent;
      default:
        return Colors.white;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m atrás';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}