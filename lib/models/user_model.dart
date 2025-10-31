class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImagePath;
  final int level;
  final int experiencePoints;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImagePath,
    required this.level,
    required this.experiencePoints,
    required this.createdAt,
    required this.lastActiveAt,
  });

  String get fullName => '$firstName $lastName';

  String get levelTitle {
    if (level == 1) return 'Semente'; // Seed
    if (level == 2) return 'Broto'; // Sprout
    if (level == 3) return 'Folinha'; // Little Leaf
    if (level == 4) return 'Mudinha'; // Seedling
    if (level == 5) return 'Plantinha'; // Little Plant
    if (level == 6) return 'Planta Jovem'; // Young Plant
    if (level == 7) return 'Planta Madura'; // Mature Plant
    if (level == 8) return 'Jardineiro'; // Gardener
    if (level == 9) return 'Mestre Jardineiro'; // Master Gardener
    if (level >= 10) return 'Guru das Plantas'; // Plant Guru
    return 'Iniciante';
  }

  int get experienceToNextLevel {
    // Progressive XP requirement: 100, 200, 300, 400, etc.
    return level * 100;
  }

  double get progressToNextLevel {
    return experiencePoints / experienceToNextLevel;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      profileImagePath: json['profileImagePath'] as String?,
      level: json['level'] as int,
      experiencePoints: json['experiencePoints'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'profileImagePath': profileImagePath,
      'level': level,
      'experiencePoints': experiencePoints,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? profileImagePath,
    int? level,
    int? experiencePoints,
    DateTime? lastActiveAt,
  }) {
    return UserProfile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
