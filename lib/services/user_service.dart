import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/achievement_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const String _userKey = 'user_profile';
  static const String _achievementsKey = 'user_achievements';
  static const String _hasUserKey = 'has_user';

  UserProfile? _currentUser;
  List<Achievement>? _achievements;

  /// Check if user exists
  Future<bool> hasUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasUserKey) ?? false;
  }

  /// Create new user
  Future<UserProfile> createUser({
    required String firstName,
    required String lastName,
    String? profileImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final user = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: firstName,
      lastName: lastName,
      profileImagePath: profileImagePath,
      level: 1,
      experiencePoints: 0,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setBool(_hasUserKey, true);

    // Initialize default achievements
    await _initializeAchievements();

    // Award "Profile Created" achievement
    await completeAchievement('profile_created');

    _currentUser = user;
    return user;
  }

  /// Load current user
  Future<UserProfile?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) return null;

    _currentUser = UserProfile.fromJson(json.decode(userJson));
    
    // Update last active
    _currentUser = _currentUser!.copyWith(lastActiveAt: DateTime.now());
    await _saveUser(_currentUser!);
    
    return _currentUser;
  }

  /// Save user to storage
  Future<void> _saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    _currentUser = user;
  }

  /// Update user profile
  Future<void> updateUser({
    String? firstName,
    String? lastName,
    String? profileImagePath,
  }) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      firstName: firstName,
      lastName: lastName,
      profileImagePath: profileImagePath,
      lastActiveAt: DateTime.now(),
    );

    await _saveUser(_currentUser!);
  }

  /// Add experience points and handle level up
  Future<bool> addExperience(int xp) async {
    if (_currentUser == null) return false;

    final newXP = _currentUser!.experiencePoints + xp;
    final currentLevel = _currentUser!.level;
    final xpNeeded = currentLevel * 100;

    bool leveledUp = false;

    if (newXP >= xpNeeded) {
      // Level up!
      _currentUser = _currentUser!.copyWith(
        level: currentLevel + 1,
        experiencePoints: newXP - xpNeeded,
        lastActiveAt: DateTime.now(),
      );
      leveledUp = true;
    } else {
      _currentUser = _currentUser!.copyWith(
        experiencePoints: newXP,
        lastActiveAt: DateTime.now(),
      );
    }

    await _saveUser(_currentUser!);
    return leveledUp;
  }

  /// Initialize achievements
  Future<void> _initializeAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);

    if (achievementsJson == null) {
      // First time - create default achievements
      final defaultAchievements = AchievementsList.getDefaultAchievements();
      await _saveAchievements(defaultAchievements);
      _achievements = defaultAchievements;
    }
  }

  /// Get all achievements
  Future<List<Achievement>> getAchievements() async {
    if (_achievements != null) return _achievements!;

    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);

    if (achievementsJson == null) {
      await _initializeAchievements();
      return _achievements ?? [];
    }

    final List<dynamic> jsonList = json.decode(achievementsJson);
    _achievements = jsonList
        .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
        .toList();

    return _achievements!;
  }

  /// Save achievements
  Future<void> _saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = achievements.map((a) => a.toJson()).toList();
    await prefs.setString(_achievementsKey, json.encode(jsonList));
    _achievements = achievements;
  }

  /// Update achievement progress
  Future<void> updateAchievementProgress(String achievementId, int progress) async {
    final achievements = await getAchievements();
    final index = achievements.indexWhere((a) => a.id == achievementId);

    if (index == -1) return;

    final achievement = achievements[index];
    if (achievement.isEarned) return;

    achievements[index] = achievement.copyWith(currentProgress: progress);

    // Check if achievement is complete
    if (progress >= achievement.targetProgress) {
      await completeAchievement(achievementId);
    } else {
      await _saveAchievements(achievements);
    }
  }

  /// Complete an achievement
  Future<bool> completeAchievement(String achievementId) async {
    final achievements = await getAchievements();
    final index = achievements.indexWhere((a) => a.id == achievementId);

    if (index == -1) return false;

    final achievement = achievements[index];
    if (achievement.isEarned) return false;

    // Mark as earned
    achievements[index] = achievement.copyWith(
      isEarned: true,
      earnedAt: DateTime.now(),
      currentProgress: achievement.targetProgress,
    );

    await _saveAchievements(achievements);

    // Award XP
    final leveledUp = await addExperience(achievement.xpReward);

    return leveledUp;
  }

  /// Get achievements by level
  Future<List<Achievement>> getAchievementsForLevel(int level) async {
    final achievements = await getAchievements();
    return achievements.where((a) => a.requiredLevel == level).toList();
  }

  /// Get earned achievements
  Future<List<Achievement>> getEarnedAchievements() async {
    final achievements = await getAchievements();
    return achievements.where((a) => a.isEarned).toList();
  }

  /// Get available achievements (unlocked but not earned)
  Future<List<Achievement>> getAvailableAchievements() async {
    if (_currentUser == null) return [];
    
    final achievements = await getAchievements();
    return achievements
        .where((a) =>
            !a.isEarned && a.requiredLevel <= _currentUser!.level)
        .toList();
  }

  /// Get locked achievements
  Future<List<Achievement>> getLockedAchievements() async {
    if (_currentUser == null) return [];
    
    final achievements = await getAchievements();
    return achievements
        .where((a) => a.requiredLevel > _currentUser!.level)
        .toList();
  }

  /// Get achievement statistics
  Future<Map<String, int>> getAchievementStats() async {
    final achievements = await getAchievements();
    final earned = achievements.where((a) => a.isEarned).length;
    final total = achievements.length;

    return {
      'earned': earned,
      'total': total,
      'percentage': ((earned / total) * 100).round(),
    };
  }

  /// Delete user and all data
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_achievementsKey);
    await prefs.remove(_hasUserKey);
    _currentUser = null;
    _achievements = null;
  }

  /// Reset achievements (for testing)
  Future<void> resetAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_achievementsKey);
    _achievements = null;
    await _initializeAchievements();
  }
}
