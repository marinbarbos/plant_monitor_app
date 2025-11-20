import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ESP32Service {
  static final ESP32Service _instance = ESP32Service._internal();
  factory ESP32Service() => _instance;
  ESP32Service._internal();

  String? _ipAddress;
  Timer? _updateTimer;
  
  static const String _ipAddressKey = 'esp32_ip_address';
  
  // Callbacks for data updates
  Function(PlantData)? onDataUpdate;
  Function(String)? onError;

  String? get ipAddress => _ipAddress;

  Future<void> setIPAddress(String ip) async {
    _ipAddress = ip;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipAddressKey, ip);
  }

  /// Load IP address from SharedPreferences
  Future<String?> loadIPAddress() async {
    if (_ipAddress != null) return _ipAddress;
    
    final prefs = await SharedPreferences.getInstance();
    _ipAddress = prefs.getString(_ipAddressKey);
    return _ipAddress;
  }

  /// Check if IP address is saved
  Future<bool> hasIPAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_ipAddressKey);
  }

  /// Clear saved IP address
  Future<void> clearIPAddress() async {
    _ipAddress = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ipAddressKey);
  }
  /// Fetch sensor data from ESP32
  Future<PlantData?> fetchSensorData() async {
    if (_ipAddress == null) {
      onError?.call('IP address not configured');
      return null;
    }

    try {
      final response = await http
          .get(Uri.parse('http://$_ipAddress/api/status'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PlantData.fromJson(data);
      } else {
        onError?.call('Failed to fetch data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      onError?.call('Connection error: $e');
      return null;
    }
  }

  /// Start periodic updates (default: every 2 minutes)
  void startPeriodicUpdates({Duration interval = const Duration(minutes: 2)}) {
    stopPeriodicUpdates(); // Stop any existing timer
    
    // Fetch immediately
    fetchSensorData().then((data) {
      if (data != null) {
        onDataUpdate?.call(data);
      }
    });

    // Then fetch periodically
    _updateTimer = Timer.periodic(interval, (timer) async {
      final data = await fetchSensorData();
      if (data != null) {
        onDataUpdate?.call(data);
      }
    });
  }

  /// Stop periodic updates
  void stopPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// Test connection to ESP32
  Future<bool> testConnection() async {
    if (_ipAddress == null) return false;

    try {
      final response = await http
          .get(Uri.parse('http://$_ipAddress/api/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Data model for plant sensor readings
class PlantData {
  final double temperature;
  final double humidity;
  final int light;
  final double soilMoisture;
  final String? status;
  final DateTime timestamp;
  final Map<String, String>? recommendations;

  PlantData({
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.soilMoisture,
    this.status,
    required this.timestamp,
    this.recommendations,
  });

  factory PlantData.fromJson(Map<String, dynamic> json) {
    return PlantData(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      light: json['light'] as int,
      soilMoisture: (json['soil_moisture'] as num).toDouble(),
      status: json['status'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      recommendations: json['recommendations'] != null
          ? Map<String, String>.from(json['recommendations'])
          : null,
    );
  }

  /// Get temperature status
  String getTemperatureStatus() {
    if (recommendations != null && recommendations!.containsKey('temperature')) {
      return recommendations!['temperature']!;
    }
    if (temperature >= 20 && temperature <= 25) return 'ideal';
    if (temperature < 20) return 'aumentar';
    return 'diminuir';
  }

  /// Get light status
  String getLightStatus() {
    if (recommendations != null && recommendations!.containsKey('light')) {
      return recommendations!['light']!;
    }
    if (light >= 400 && light <= 800) return 'ideal';
    if (light < 400) return 'aumentar';
    return 'diminuir';
  }

  /// Get soil moisture status
  String getSoilMoistureStatus() {
    if (recommendations != null && recommendations!.containsKey('soil_moisture')) {
      return recommendations!['soil_moisture']!;
    }
    if (soilMoisture >= 50 && soilMoisture <= 70) return 'ideal';
    if (soilMoisture < 50) return 'aumentar';
    return 'diminuir';
  }

  /// Get light description
  String getLightDescription() {
    if (light > 500) return 'Claro';
    return 'Escuro';
  }

  /// Calculate overall plant health score (0-100)
  int getHealthScore() {
    int score = 100;
    
    // Temperature penalty
    if (temperature < 18 || temperature > 28) {
      score -= 30;
    } else if (temperature < 20 || temperature > 25) {
      score -= 15;
    }
    
    // Light penalty
    if (light < 300 || light > 900) {
      score -= 30;
    } else if (light < 400 || light > 800) {
      score -= 15;
    }
    
    // Soil moisture penalty
    if (soilMoisture < 35 || soilMoisture > 75) {
      score -= 30;
    } else if (soilMoisture < 50 || soilMoisture > 70) {
      score -= 15;
    }
    
    return score.clamp(0, 100);
  }

  /// Get plant status based on health score
  PlantStatus getPlantStatus() {
    final score = getHealthScore();
    
    if (score >= 80) {
      return PlantStatus.thriving;
    } else if (score >= 60) {
      return PlantStatus.healthy;
    } else if (score >= 40) {
      return PlantStatus.stressed;
    } else if (score >= 20) {
      return PlantStatus.struggling;
    } else {
      return PlantStatus.critical;
    }
  }
}

/// Plant health status levels
enum PlantStatus {
  thriving,    // 80-100: Perfect conditions
  healthy,     // 60-79: Good conditions
  stressed,    // 40-59: Needs attention
  struggling,  // 20-39: Poor conditions
  critical,    // 0-19: Critical conditions
}

/// Extension to get display info for plant status
extension PlantStatusExtension on PlantStatus {
  String get emoji {
    switch (this) {
      case PlantStatus.thriving:
        return '😊';
      case PlantStatus.healthy:
        return '🙂';
      case PlantStatus.stressed:
        return '😐';
      case PlantStatus.struggling:
        return '☹️';
      case PlantStatus.critical:
        return '😰';
    }
  }

  String get name {
    switch (this) {
      case PlantStatus.thriving:
        return 'Florescendo';  // Thriving
      case PlantStatus.healthy:
        return 'Saudável';     // Healthy
      case PlantStatus.stressed:
        return 'Estressada';   // Stressed
      case PlantStatus.struggling:
        return 'Sofrendo';     // Struggling
      case PlantStatus.critical:
        return 'Crítico';      // Critical
    }
  }

  String get description {
    switch (this) {
      case PlantStatus.thriving:
        return 'Sua planta está em condições perfeitas!';
      case PlantStatus.healthy:
        return 'Sua planta está se desenvolvendo bem.';
      case PlantStatus.stressed:
        return 'Sua planta precisa de atenção.';
      case PlantStatus.struggling:
        return 'Sua planta está em dificuldade!';
      case PlantStatus.critical:
        return 'Condições críticas! Ação imediata necessária!';
    }
  }

  String get imagePath {
    switch (this) {
      case PlantStatus.thriving:
        return 'assets/images/plant_thriving.png';
      case PlantStatus.healthy:
        return 'assets/images/plant_healthy.png';
      case PlantStatus.stressed:
        return 'assets/images/plant_stressed.png';
      case PlantStatus.struggling:
        return 'assets/images/plant_struggling.png';
      case PlantStatus.critical:
        return 'assets/images/plant_critical.png';
    }
  }

  Color get statusColor {
    switch (this) {
      case PlantStatus.thriving:
        return const Color(0xFF4CAF50); // Green
      case PlantStatus.healthy:
        return const Color(0xFF8BC34A); // Light green
      case PlantStatus.stressed:
        return const Color(0xFFFFC107); // Amber
      case PlantStatus.struggling:
        return const Color(0xFFFF9800); // Orange
      case PlantStatus.critical:
        return const Color(0xFFF44336); // Red
    }
  }
}
