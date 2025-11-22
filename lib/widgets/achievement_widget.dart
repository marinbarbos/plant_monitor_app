import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/achievement_model.dart';
import '../services/user_service.dart';
import '../services/achievement_tracker.dart';

/// Collection of reusable achievement-related widgets
class AchievementWidgets {
  /// Show level up dialog
  static Future<void> showLevelUpDialog(
    BuildContext context, {
    UserProfile? user,
  }) async {
    // If user not provided, fetch it
    user ??= await UserService().getCurrentUser();
    if (user == null) return;
    if(context.mounted) {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: _LevelUpDialogContent(user: user!),
        ),
      );
    }
  }

  /// Show achievement unlocked notification
  static Future<void> showAchievementUnlocked(
    BuildContext context,
    Achievement achievement,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _AchievementUnlockedContent(achievement: achievement),
      ),
    );
  }

  /// Show multiple achievements unlocked (for batch unlocks)
  static Future<void> showMultipleAchievements(
    BuildContext context,
    List<Achievement> achievements,
  ) async {
    for (final achievement in achievements) {

      if(context.mounted) {
        await showAchievementUnlocked(context, achievement);
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Show XP gained notification (snackbar style)
  static void showXPGained(BuildContext context, int xp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 12),
            Text(
              '+$xp XP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Show level up notification (lightweight, no dialog)
  static void showQuickLevelUp(BuildContext context, UserProfile user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SUBIU DE NÍVEL!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Nível ${user.level}: ${user.levelTitle}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber[800],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// Level Up Dialog Content
class _LevelUpDialogContent extends StatefulWidget {
  final UserProfile user;

  const _LevelUpDialogContent({required this.user});

  @override
  State<_LevelUpDialogContent> createState() => _LevelUpDialogContentState();
}

class _LevelUpDialogContentState extends State<_LevelUpDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.amber,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha:0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration Icon
              const Icon(
                Icons.celebration,
                color: Colors.amber,
                size: 64,
              ),
              const SizedBox(height: 16),

              // "Level Up!" Text
              const Text(
                'SUBIU DE NÍVEL!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),

              // Emoji
              const Text(
                '🎉',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),

              // Level Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber,
                      Colors.amber[700]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha:0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'NÍVEL ${widget.user.level}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.levelTitle,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Motivational Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha:0.3),
                  ),
                ),
                child: Text(
                  _getMotivationalMessage(widget.user.level),
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMotivationalMessage(int level) {
    if (level == 2) return 'Você está crescendo! Continue assim! 🌱';
    if (level == 3) return 'Suas plantas estão prosperando! 🌿';
    if (level == 4) return 'Você está se tornando um expert! 🌳';
    if (level == 5) return 'Habilidades de jardineiro impressionantes! 🏆';
    if (level == 6) return 'Você dominou o básico! 🎯';
    if (level == 7) return 'Mestre em crescimento de plantas! ⭐';
    if (level == 8) return 'Jardineiro extraordinário! 🌟';
    if (level == 9) return 'Você está quase no topo! 👑';
    if (level >= 10) return 'Guru das plantas alcançado! 🎖️';
    return 'Continue crescendo! 🌱';
  }
}

/// Achievement Unlocked Dialog Content
class _AchievementUnlockedContent extends StatefulWidget {
  final Achievement achievement;

  const _AchievementUnlockedContent({required this.achievement});

  @override
  State<_AchievementUnlockedContent> createState() =>
      _AchievementUnlockedContentState();
}

class _AchievementUnlockedContentState
    extends State<_AchievementUnlockedContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.achievement.difficulty.color,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.achievement.difficulty.color.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy Icon
                const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 48,
                ),
                const SizedBox(height: 12),

                // "Achievement Unlocked" Text
                Text(
                  'CONQUISTA DESBLOQUEADA!',
                  style: TextStyle(
                    color: widget.achievement.difficulty.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Achievement Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.achievement.difficulty.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.achievement.icon,
                    size: 48,
                    color: widget.achievement.difficulty.color,
                  ),
                ),
                const SizedBox(height: 16),

                // Achievement Name
                Text(
                  widget.achievement.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  widget.achievement.description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // XP Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '+${widget.achievement.xpReward} XP',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Tap to dismiss hint
                Text(
                  'Toque para fechar',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mixin to easily add achievement dialogs to any screen
mixin AchievementDialogMixin<T extends StatefulWidget> on State<T> {
  /// Show level up dialog
  Future<void> showLevelUpDialog() async {
    await AchievementWidgets.showLevelUpDialog(context);
  }

  /// Show achievement unlocked dialog
  Future<void> showAchievementUnlocked(Achievement achievement) async {
    await AchievementWidgets.showAchievementUnlocked(context, achievement);
  }

  /// Show XP gained notification
  void showXPGained(int xp) {
    AchievementWidgets.showXPGained(context, xp);
  }

  /// Show quick level up notification (snackbar)
  void showQuickLevelUp(UserProfile user) {
    AchievementWidgets.showQuickLevelUp(context, user);
  }
}

/// Mixin for centralized achievement tracking with automatic UI feedback
mixin AchievementNotificationMixin<T extends StatefulWidget> on State<T> {
  
  /// Track an achievement and show level up dialog if leveled up
  Future<void> trackAndNotify(Future<bool> Function() trackingFunction) async {
    final leveledUp = await trackingFunction();
    
    if (leveledUp && mounted) {
      await AchievementWidgets.showLevelUpDialog(context);
    }
  }
  
  /// Track card unlock achievement
  Future<void> trackCardUnlock(int totalUnlockedCount) async {
    await trackAndNotify(() => 
      AchievementTracker().onCardUnlocked(totalUnlockedCount)
    );
  }
  
  /// Track favorite added achievement
  Future<void> trackFavoriteAdded(int totalFavoritesCount) async {
    await trackAndNotify(() => 
      AchievementTracker().onFavoriteAdded(totalFavoritesCount)
    );
  }
  
  /// Track first connection achievement
  Future<void> trackFirstConnection() async {
    await trackAndNotify(() => 
      AchievementTracker().onFirstConnection()
    );
  }
  
  /// Track daily check-in
  Future<void> trackDailyCheckIn() async {
    await trackAndNotify(() => 
      AchievementTracker().markDailyCheckIn()
    );
  }
  
  /// Track plant health achievement
  Future<void> trackHealthUpdate(int healthScore) async {
    await trackAndNotify(() => 
      AchievementTracker().onHealthUpdate(healthScore)
    );
  }
  
  /// Track ideal temperature achievement
  Future<void> trackIdealTemperature() async {
    await trackAndNotify(() => 
      AchievementTracker().onIdealTemperature()
    );
  }
  
  /// Track ideal moisture achievement
  Future<void> trackIdealMoisture() async {
    await trackAndNotify(() => 
      AchievementTracker().onIdealMoisture()
    );
  }
  
  /// Track light adjustment achievement
  Future<void> trackLightAdjustment() async {
    await trackAndNotify(() => 
      AchievementTracker().onLightAdjustment()
    );
  }
  
  /// Track profile creation achievement (already completed in UserService)
  Future<void> trackProfileCreated() async {
    // Profile created achievement is already handled in UserService
    // This can be called to show any related UI feedback if needed
    final user = await UserService().getCurrentUser();
    if (user != null && mounted) {
      // Could show welcome message or tour here
    }
  }
}