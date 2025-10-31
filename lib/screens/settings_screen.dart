import 'package:flutter/material.dart';
import 'ip_entry_screen.dart';
import '../widgets/navbar.dart';
import '../services/user_service.dart';
import '../services/cards_service.dart';
import '../services/favorites_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  final CardsService _cardsService = CardsService();
  final FavoritesService _favoritesService = FavoritesService();

  Future<void> _showResetDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllCards() async {
    await _cardsService.resetAllCards();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os cards foram bloqueados'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _unlockAllCards() async {
    await _cardsService.unlockAllCards();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os cards foram desbloqueados'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _clearFavorites() async {
    await _favoritesService.clearAllFavorites();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favoritos removidos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _resetAchievements() async {
    await _userService.resetAchievements();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conquistas resetadas'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _deleteAllData() async {
    await _userService.deleteUser();
    await _cardsService.resetAllCards();
    await _favoritesService.clearAllFavorites();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os dados foram apagados'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate to splash screen to restart
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MicroGardenAppBar(
        titleWidget: Row(
          children: [
            Icon(Icons.settings, color: Colors.grey, size: 24),
            SizedBox(width: 8),
            Text('CONFIGURAÇÕES', style: TextStyle(color: Colors.grey)),
          ],
        ),
        showBackButton: true,
      ),
      backgroundColor: const Color(0xFF2C2C2C),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Connection Section
          _buildSectionHeader('Conexão', Icons.wifi),
          _buildSettingsCard(
            title: 'Reconfigurar IP do ESP32',
            subtitle: 'Conectar a um novo dispositivo',
            icon: Icons.router,
            iconColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IPInputPage()),
              );
            },
          ),
          const SizedBox(height: 24),

          // Development Tools Section
          _buildSectionHeader('Ferramentas de Desenvolvimento', Icons.build),
          _buildSettingsCard(
            title: 'Desbloquear Todos os Cards',
            subtitle: 'Para teste e desenvolvimento',
            icon: Icons.lock_open,
            iconColor: Colors.amber,
            onTap: () {
              _showResetDialog(
                title: 'Desbloquear Cards',
                message: 'Desbloquear todos os cards? Útil para testar o app.',
                onConfirm: _unlockAllCards,
              );
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsCard(
            title: 'Bloquear Todos os Cards',
            subtitle: 'Resetar progresso dos cards',
            icon: Icons.lock,
            iconColor: Colors.orange,
            onTap: () {
              _showResetDialog(
                title: 'Bloquear Cards',
                message: 'Tem certeza? Todos os cards serão bloqueados novamente.',
                onConfirm: _resetAllCards,
              );
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsCard(
            title: 'Limpar Favoritos',
            subtitle: 'Remover todos os favoritos',
            icon: Icons.favorite_border,
            iconColor: Colors.pink,
            onTap: () {
              _showResetDialog(
                title: 'Limpar Favoritos',
                message: 'Remover todos os cards dos favoritos?',
                onConfirm: _clearFavorites,
              );
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsCard(
            title: 'Resetar Conquistas',
            subtitle: 'Reiniciar todas as conquistas',
            icon: Icons.emoji_events,
            iconColor: Colors.purple,
            onTap: () {
              _showResetDialog(
                title: 'Resetar Conquistas',
                message: 'Resetar todas as conquistas? O nível e XP serão mantidos.',
                onConfirm: _resetAchievements,
              );
            },
          ),
          const SizedBox(height: 24),

          // Danger Zone Section
          _buildSectionHeader('Zona de Perigo', Icons.warning, color: Colors.red),
          _buildSettingsCard(
            title: 'Apagar Todos os Dados',
            subtitle: 'Remove perfil, conquistas e progresso',
            icon: Icons.delete_forever,
            iconColor: Colors.red,
            isDanger: true,
            onTap: () {
              _showResetDialog(
                title: 'Apagar Dados',
                message:
                    'ATENÇÃO: Isso irá apagar TODOS os dados incluindo perfil, conquistas, cards e favoritos. Esta ação não pode ser desfeita!',
                onConfirm: _deleteAllData,
              );
            },
          ),
          const SizedBox(height: 40),

          // App Info Section
          _buildSectionHeader('Sobre', Icons.info_outline),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // App Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 40,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Micro Garden',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Versão 0.0.1',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[700]),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.code, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Desenvolvido por',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Marina Barbosa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    // Could open email client
                  },
                  child: Text(
                    'mb.americo@unesp.br',
                    style: TextStyle(
                      color: Colors.green[300],
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.eco, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Cuide bem das suas plantas! 🌱',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.grey[400], size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color ?? Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
              border: isDanger
                  ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDanger ? Colors.red[300] : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}