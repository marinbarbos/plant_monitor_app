import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../models/user_model.dart';
import '../models/achievement_model.dart';
import '../services/user_service.dart';
import 'create_user_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  UserProfile? _user;
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final hasUser = await _userService.hasUser();
      
      if (!hasUser) {
        // Navigate to create user screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CreateUserScreen()),
          );
        }
        return;
      }

      final user = await _userService.getCurrentUser();
      final achievements = await _userService.getAchievements();

      if (mounted) {
        setState(() {
          _user = user;
          _achievements = achievements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar perfil: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: const MicroGardenAppBar(
          titleWidget: Text('PROFILE', style: TextStyle(color: Colors.grey)),
          showBackButton: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const CreateUserScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: const MicroGardenAppBar(
        titleWidget: Text('PROFILE', style: TextStyle(color: Colors.grey)),
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Profile Header
          _buildProfileHeader(),

          // Tabs
          Container(
            color: Colors.grey[900],
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.green,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Disponíveis'),
                Tab(text: 'Conquistados'),
                Tab(text: 'Bloqueados'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvailableTab(),
                _buildEarnedTab(),
                _buildLockedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final stats = _achievements.where((a) => a.isEarned).length;
    final total = _achievements.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[850]!,
            const Color(0xFF1E1E1E),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Picture and Name
          Row(
            children: [
              // Profile Picture
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 3),
                  color: Colors.grey[800],
                ),
                child: _user!.profileImagePath != null
                    ? ClipOval(
                        child: Image.asset(
                          _user!.profileImagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 40, color: Colors.grey);
                          },
                        ),
                      )
                    : const Icon(Icons.person, size: 40, color: Colors.grey),
              ),
              const SizedBox(width: 20),
              // Name and Level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user!.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        'Nível ${_user!.level}: ${_user!.levelTitle}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // XP Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Experiência',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    Text(
                      '${_user!.experiencePoints} / ${_user!.experienceToNextLevel} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _user!.progressToNextLevel,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Achievement Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Conquistas',
                  '$stats/$total',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Progresso',
                  '${((stats / total) * 100).toStringAsFixed(0)}%',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTab() {
    final available = _achievements
        .where((a) => !a.isEarned && a.requiredLevel <= _user!.level)
        .toList();

    if (available.isEmpty) {
      return _buildEmptyState(
        'Nenhuma Conquista Disponível',
        'Suba de nível para desbloquear mais conquistas!',
        Icons.lock_clock,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: available.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(available[index], isAvailable: true);
      },
    );
  }

  Widget _buildEarnedTab() {
    final earned = _achievements.where((a) => a.isEarned).toList();

    if (earned.isEmpty) {
      return _buildEmptyState(
        'Nenhuma Conquista Ainda',
        'Complete desafios para ganhar conquistas!',
        Icons.emoji_events_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: earned.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(earned[index], isEarned: true);
      },
    );
  }

  Widget _buildLockedTab() {
    final locked = _achievements
        .where((a) => a.requiredLevel > _user!.level)
        .toList();

    if (locked.isEmpty) {
      return _buildEmptyState(
        'Todas Desbloqueadas!',
        'Você desbloqueou todas as conquistas disponíveis!',
        Icons.check_circle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: locked.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(locked[index], isLocked: true);
      },
    );
  }

  Widget _buildAchievementCard(
    Achievement achievement, {
    bool isEarned = false,
    bool isAvailable = false,
    bool isLocked = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned
              ? Colors.green
              : (isLocked ? Colors.grey[700]! : achievement.difficulty.color),
          width: isEarned ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isLocked
                  ? Colors.grey[800]
                  : achievement.difficulty.color.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              achievement.icon,
              color: isLocked ? Colors.grey : achievement.difficulty.color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.name,
                        style: TextStyle(
                          color: isLocked ? Colors.grey : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isEarned)
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: achievement.difficulty.color.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        achievement.difficulty.label,
                        style: TextStyle(
                          color: achievement.difficulty.color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${achievement.xpReward} XP',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isLocked) ...[
                      const Spacer(),
                      Text(
                        'Nível ${achievement.requiredLevel}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ],
                ),
                if (isAvailable && achievement.targetProgress > 1) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: achievement.progressPercentage,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      achievement.difficulty.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.currentProgress}/${achievement.targetProgress}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}