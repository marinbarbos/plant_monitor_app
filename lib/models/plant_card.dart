import 'package:flutter/material.dart';

class PlantCard {
  final String id;
  final String name;
  final String scientificName;
  final String image;
  final bool unlocked;
  final String summary;
  final String description;
  final String growthTime;
  final String difficulty;
  final String season;
  final String idealTemperature;
  final String idealLight;
  final String wateringFrequency;
  final String soilMoisture;
  final String harvestHeight;

  PlantCard({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.image,
    required this.unlocked,
    required this.summary,
    required this.description,
    required this.growthTime,
    required this.difficulty,
    required this.season,
    required this.idealTemperature,
    required this.idealLight,
    required this.wateringFrequency,
    required this.soilMoisture,
    required this.harvestHeight,
  });

  factory PlantCard.fromJson(Map<String, dynamic> json) {
    return PlantCard(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientificName'] as String,
      image: json['image'] as String,
      unlocked: json['unlocked'] as bool? ?? false,
      summary: json['summary'] as String,
      description: json['description'] as String,
      growthTime: json['growthTime'] as String,
      difficulty: json['difficulty'] as String,
      season: json['season'] as String,
      idealTemperature: json['idealTemperature'] as String,
      idealLight: json['idealLight'] as String,
      wateringFrequency: json['wateringFrequency'] as String,
      soilMoisture: json['soilMoisture'] as String,
      harvestHeight: json['harvestHeight'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'image': image,
      'unlocked': unlocked,
      'summary': summary,
      'description': description,
      'growthTime': growthTime,
      'difficulty': difficulty,
      'season': season,
      'idealTemperature': idealTemperature,
      'idealLight': idealLight,
      'wateringFrequency': wateringFrequency,
      'soilMoisture': soilMoisture,
      'harvestHeight': harvestHeight,
    };
  }

  PlantCard copyWith({bool? unlocked}) {
    return PlantCard(
      id: id,
      name: name,
      scientificName: scientificName,
      image: image,
      unlocked: unlocked ?? this.unlocked,
      summary: summary,
      description: description,
      growthTime: growthTime,
      difficulty: difficulty,
      season: season,
      idealTemperature: idealTemperature,
      idealLight: idealLight,
      wateringFrequency: wateringFrequency,
      soilMoisture: soilMoisture,
      harvestHeight: harvestHeight,
    );
  }

  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'muito fácil':
        return const Color(0xFF4CAF50); // Green
      case 'fácil':
        return const Color(0xFF8BC34A); // Light green
      case 'médio':
        return const Color(0xFFFFC107); // Amber
      case 'médio-difícil':
        return const Color(0xFFFF9800); // Orange
      case 'difícil':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  IconData get difficultyIcon {
    switch (difficulty.toLowerCase()) {
      case 'muito fácil':
        return Icons.sentiment_very_satisfied;
      case 'fácil':
        return Icons.sentiment_satisfied;
      case 'médio':
        return Icons.sentiment_neutral;
      case 'médio-difícil':
        return Icons.sentiment_dissatisfied;
      case 'difícil':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }
}