import 'package:flutter/material.dart';

enum AchievementDifficulty {
  easy,
  medium,
  hard,
  expert,
}

extension AchievementDifficultyExtension on AchievementDifficulty {
  int get xpReward {
    switch (this) {
      case AchievementDifficulty.easy:
        return 10;
      case AchievementDifficulty.medium:
        return 25;
      case AchievementDifficulty.hard:
        return 50;
      case AchievementDifficulty.expert:
        return 100;
    }
  }

  String get label {
    switch (this) {
      case AchievementDifficulty.easy:
        return 'Fácil';
      case AchievementDifficulty.medium:
        return 'Médio';
      case AchievementDifficulty.hard:
        return 'Difícil';
      case AchievementDifficulty.expert:
        return 'Expert';
    }
  }

  Color get color {
    switch (this) {
      case AchievementDifficulty.easy:
        return const Color(0xFF4CAF50); // Green
      case AchievementDifficulty.medium:
        return const Color(0xFFFFC107); // Amber
      case AchievementDifficulty.hard:
        return const Color(0xFFFF9800); // Orange
      case AchievementDifficulty.expert:
        return const Color(0xFFF44336); // Red
    }
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final AchievementDifficulty difficulty;
  final int requiredLevel; // Minimum level to unlock this achievement
  final bool isEarned;
  final DateTime? earnedAt;
  final int currentProgress;
  final int targetProgress;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.difficulty,
    this.requiredLevel = 1,
    this.isEarned = false,
    this.earnedAt,
    this.currentProgress = 0,
    this.targetProgress = 1,
  });

  double get progressPercentage {
    if (targetProgress == 0) return 0;
    return (currentProgress / targetProgress).clamp(0.0, 1.0);
  }

  bool get isUnlocked => requiredLevel <= 1; // Will be checked against user level

  int get xpReward => difficulty.xpReward;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: 'MaterialIcons',
      ),
      difficulty: AchievementDifficulty.values[json['difficulty'] as int],
      requiredLevel: json['requiredLevel'] as int? ?? 1,
      isEarned: json['isEarned'] as bool? ?? false,
      earnedAt: json['earnedAt'] != null
          ? DateTime.parse(json['earnedAt'] as String)
          : null,
      currentProgress: json['currentProgress'] as int? ?? 0,
      targetProgress: json['targetProgress'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'difficulty': difficulty.index,
      'requiredLevel': requiredLevel,
      'isEarned': isEarned,
      'earnedAt': earnedAt?.toIso8601String(),
      'currentProgress': currentProgress,
      'targetProgress': targetProgress,
    };
  }

  Achievement copyWith({
    bool? isEarned,
    DateTime? earnedAt,
    int? currentProgress,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      difficulty: difficulty,
      requiredLevel: requiredLevel,
      isEarned: isEarned ?? this.isEarned,
      earnedAt: earnedAt ?? this.earnedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress,
    );
  }
}

// Predefined achievements
class AchievementsList {
  static List<Achievement> getDefaultAchievements() {
    return [
      // Level 1 - Beginner Achievements
      Achievement(
        id: 'first_card',
        name: 'Primeira Descoberta',
        description: 'Desbloqueie seu primeiro card',
        icon: Icons.style,
        difficulty: AchievementDifficulty.easy,
        requiredLevel: 1,
        targetProgress: 1,
      ),
      Achievement(
        id: 'profile_created',
        name: 'Bem-vindo!',
        description: 'Crie seu perfil',
        icon: Icons.person_add,
        difficulty: AchievementDifficulty.easy,
        requiredLevel: 1,
        targetProgress: 1,
      ),
      Achievement(
        id: 'first_connection',
        name: 'Conectado',
        description: 'Conecte-se ao ESP32 pela primeira vez',
        icon: Icons.wifi,
        difficulty: AchievementDifficulty.easy,
        requiredLevel: 1,
        targetProgress: 1,
      ),
      Achievement(
        id: 'first_favorite',
        name: 'Favorito Especial',
        description: 'Adicione seu primeiro card aos favoritos',
        icon: Icons.favorite,
        difficulty: AchievementDifficulty.easy,
        requiredLevel: 1,
        targetProgress: 1,
      ),

      // Level 2 - Intermediate Achievements
      Achievement(
        id: 'card_collector_5',
        name: 'Colecionador',
        description: 'Desbloqueie 5 cards diferentes',
        icon: Icons.collections,
        difficulty: AchievementDifficulty.medium,
        requiredLevel: 2,
        targetProgress: 5,
      ),
      Achievement(
        id: 'plant_health_perfect',
        name: 'Cuidador Dedicado',
        description: 'Mantenha sua planta com saúde 80+ por 24 horas',
        icon: Icons.favorite_border,
        difficulty: AchievementDifficulty.medium,
        requiredLevel: 2,
        targetProgress: 1,
      ),
      Achievement(
        id: 'daily_check_7',
        name: 'Rotina Saudável',
        description: 'Verifique sua planta 7 dias seguidos',
        icon: Icons.event_repeat,
        difficulty: AchievementDifficulty.medium,
        requiredLevel: 2,
        targetProgress: 7,
      ),

      // Level 3 - Advanced Achievements
      Achievement(
        id: 'all_cards',
        name: 'Mestre Colecionador',
        description: 'Desbloqueie todos os cards',
        icon: Icons.emoji_events,
        difficulty: AchievementDifficulty.hard,
        requiredLevel: 3,
        targetProgress: 8,
      ),
      Achievement(
        id: 'temperature_master',
        name: 'Mestre da Temperatura',
        description: 'Mantenha temperatura ideal por 7 dias',
        icon: Icons.thermostat,
        difficulty: AchievementDifficulty.hard,
        requiredLevel: 3,
        targetProgress: 7,
      ),
      Achievement(
        id: 'light_expert',
        name: 'Expert em Luz',
        description: 'Ajuste a luz corretamente 20 vezes',
        icon: Icons.wb_sunny,
        difficulty: AchievementDifficulty.hard,
        requiredLevel: 3,
        targetProgress: 20,
      ),

      // Level 4+ - Expert Achievements
      Achievement(
        id: 'plant_guru',
        name: 'Guru das Plantas',
        description: 'Alcance nível 5',
        icon: Icons.workspace_premium,
        difficulty: AchievementDifficulty.expert,
        requiredLevel: 4,
        targetProgress: 1,
      ),
      Achievement(
        id: 'perfect_month',
        name: 'Mês Perfeito',
        description: 'Mantenha saúde da planta 90+ por 30 dias',
        icon: Icons.stars,
        difficulty: AchievementDifficulty.expert,
        requiredLevel: 4,
        targetProgress: 30,
      ),
      Achievement(
        id: 'water_master',
        name: 'Mestre da Irrigação',
        description: 'Mantenha umidade do solo ideal por 30 dias',
        icon: Icons.water_drop,
        difficulty: AchievementDifficulty.expert,
        requiredLevel: 4,
        targetProgress: 30,
      ),
    ];
  }
}
