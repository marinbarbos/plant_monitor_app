import 'package:shared_preferences/shared_preferences.dart';
import 'user_service.dart';
import 'cards_service.dart';
import 'favorites_service.dart';

/// Centralized achievement tracking service
/// Monitors user actions and updates achievement progress automatically
class AchievementTracker {
  static final AchievementTracker _instance = AchievementTracker._internal();
  factory AchievementTracker() => _instance;
  AchievementTracker._internal();

  final UserService _userService = UserService();
  final CardsService _cardsService = CardsService();
  final FavoritesService _favoritesService = FavoritesService();
 // final AlbumService _albumService = AlbumService();

  // Storage keys for tracking counts
  static const String _lastCheckDateKey = 'last_check_date';
  static const String _consecutiveDaysKey = 'consecutive_days';
  static const String _lightAdjustmentsKey = 'light_adjustments_count';
  static const String _perfectHealthDaysKey = 'perfect_health_days';
  static const String _idealTempDaysKey = 'ideal_temp_days';
  static const String _idealMoistureDaysKey = 'ideal_moisture_days';

  /// Initialize tracker - call this on app startup
  Future<void> initialize() async {
    await _checkDailyStreak();
  }

  // ==================== CARD ACHIEVEMENTS ====================

  /// Track card unlocking
  Future<bool> onCardUnlocked(int cardCount) async {
    bool leveledUp = false;

    final unlockedCount = cardCount;

    // First card achievement
    if (unlockedCount == 1) {
      leveledUp = await _userService.completeAchievement('first_card') || leveledUp;
    }

    // Update collector progress (5 cards)
    await _userService.updateAchievementProgress(
      'card_collector_5',
      unlockedCount,
    );

    // All cards achievement (8 total)
    if (unlockedCount == 8) {
      leveledUp = await _userService.completeAchievement('all_cards') || leveledUp;
    }

    return leveledUp;
  }

  // ==================== FAVORITES ACHIEVEMENTS ====================

  /// Track favorite additions
  Future<bool> onFavoriteAdded(int count) async {
  
    // First favorite
    if (count == 1) {
      return await _userService.completeAchievement('first_favorite');
    }

    return false;
  }

  // ==================== CONNECTION ACHIEVEMENTS ====================

  /// Track ESP32 connection (call once on successful connection)
  Future<bool> onFirstConnection() async {
    return await _userService.completeAchievement('first_connection');
  }

  // ==================== DAILY CHECK-IN ACHIEVEMENTS ====================

  /// Check daily streak - call this when app opens
  Future<void> _checkDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastCheckStr = prefs.getString(_lastCheckDateKey);

    if (lastCheckStr == todayStr) {
      // Already checked in today
      return;
    }

    // Check if yesterday
    DateTime? lastCheck;
    if (lastCheckStr != null) {
      final parts = lastCheckStr.split('-');
      lastCheck = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    int consecutiveDays = prefs.getInt(_consecutiveDaysKey) ?? 0;

    if (lastCheck != null) {
      final difference = today.difference(lastCheck).inDays;
      
      if (difference == 1) {
        // Consecutive day!
        consecutiveDays++;
      } else if (difference > 1) {
        // Streak broken
        consecutiveDays = 1;
      }
    } else {
      // First check-in
      consecutiveDays = 1;
    }

    // Save new streak
    await prefs.setString(_lastCheckDateKey, todayStr);
    await prefs.setInt(_consecutiveDaysKey, consecutiveDays);

    // Update achievement progress (7 days)
    await _userService.updateAchievementProgress(
      'daily_check_7',
      consecutiveDays,
    );
  }

  /// Manually mark daily check-in (call when user opens dashboard)
  Future<bool> markDailyCheckIn() async {
    await _checkDailyStreak();
    return false;
  }

  /// Get current streak
  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_consecutiveDaysKey) ?? 0;
  }

  // ==================== PLANT HEALTH ACHIEVEMENTS ====================

  /// Track plant health score - call this from dashboard updates
  Future<bool> onHealthUpdate(int healthScore) async {
    bool leveledUp = false;

    if (healthScore >= 80) {
      leveledUp = await _trackPerfectHealth() || leveledUp;
    } else {
      await _resetPerfectHealth();
    }

    return leveledUp;
  }

  Future<bool> _trackPerfectHealth() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastPerfectStr = prefs.getString('last_perfect_health_date');

    if (lastPerfectStr == todayStr) {
      // Already counted today
      return false;
    }

    // Increment counter
    int perfectDays = prefs.getInt(_perfectHealthDaysKey) ?? 0;
    perfectDays++;

    await prefs.setString('last_perfect_health_date', todayStr);
    await prefs.setInt(_perfectHealthDaysKey, perfectDays);

    // Check achievements
    bool leveledUp = false;

    // 24 hours (1 day) achievement
    if (perfectDays >= 1) {
      leveledUp = await _userService.completeAchievement('plant_health_perfect') || leveledUp;
    }

    // 30 days achievement
    await _userService.updateAchievementProgress('perfect_month', perfectDays);

    return leveledUp;
  }

  Future<void> _resetPerfectHealth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_perfectHealthDaysKey, 0);
    await prefs.remove('last_perfect_health_date');
  }

  // ==================== TEMPERATURE ACHIEVEMENTS ====================

  /// Track ideal temperature - call daily from dashboard
  Future<bool> onIdealTemperature() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastIdealStr = prefs.getString('last_ideal_temp_date');

    if (lastIdealStr == todayStr) {
      return false;
    }

    int idealDays = prefs.getInt(_idealTempDaysKey) ?? 0;
    idealDays++;

    await prefs.setString('last_ideal_temp_date', todayStr);
    await prefs.setInt(_idealTempDaysKey, idealDays);

    // Update achievement (7 days)
    await _userService.updateAchievementProgress('temperature_master', idealDays);

    return false;
  }

  // ==================== LIGHT ADJUSTMENTS ====================

  /// Track light adjustments - call when user improves light conditions
  Future<bool> onLightAdjustment() async {
    final prefs = await SharedPreferences.getInstance();
    int adjustments = prefs.getInt(_lightAdjustmentsKey) ?? 0;
    adjustments++;

    await prefs.setInt(_lightAdjustmentsKey, adjustments);

    // Update achievement (20 adjustments)
    await _userService.updateAchievementProgress('light_expert', adjustments);

    return false;
  }

  // ==================== SOIL MOISTURE ACHIEVEMENTS ====================

  /// Track ideal moisture - call daily from dashboard
  Future<bool> onIdealMoisture() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastIdealStr = prefs.getString('last_ideal_moisture_date');

    if (lastIdealStr == todayStr) {
      return false;
    }

    int idealDays = prefs.getInt(_idealMoistureDaysKey) ?? 0;
    idealDays++;

    await prefs.setString('last_ideal_moisture_date', todayStr);
    await prefs.setInt(_idealMoistureDaysKey, idealDays);

    // Update achievement (30 days)
    await _userService.updateAchievementProgress('water_master', idealDays);

    return false;
  }

  // ==================== HELPER METHODS ====================

  /// Check multiple achievements at once and return if any level up occurred
  Future<bool> checkMultiple(List<Future<bool> Function()> checks) async {
    bool anyLevelUp = false;
    
    for (final check in checks) {
      final result = await check();
      anyLevelUp = anyLevelUp || result;
    }

    return anyLevelUp;
  }

  /// Get all tracked statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'consecutive_days': prefs.getInt(_consecutiveDaysKey) ?? 0,
      'light_adjustments': prefs.getInt(_lightAdjustmentsKey) ?? 0,
      'perfect_health_days': prefs.getInt(_perfectHealthDaysKey) ?? 0,
      'ideal_temp_days': prefs.getInt(_idealTempDaysKey) ?? 0,
      'ideal_moisture_days': prefs.getInt(_idealMoistureDaysKey) ?? 0,
      'unlocked_cards': _cardsService.getUnlockedCount(),
      'favorites_count': await _favoritesService.getFavoriteCount(),
      //'total_plants': _albumService.getTotalCount(),
    };
  }

  /// Reset all tracked statistics (for testing)
  Future<void> resetAllTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastCheckDateKey);
    await prefs.remove(_consecutiveDaysKey);
    await prefs.remove(_lightAdjustmentsKey);
    await prefs.remove(_perfectHealthDaysKey);
    await prefs.remove(_idealTempDaysKey);
    await prefs.remove(_idealMoistureDaysKey);
    await prefs.remove('last_perfect_health_date');
    await prefs.remove('last_ideal_temp_date');
    await prefs.remove('last_ideal_moisture_date');
  }
}
