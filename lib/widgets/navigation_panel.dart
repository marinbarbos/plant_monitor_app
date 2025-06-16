import 'package:flutter/material.dart';

class NavigationPanel extends StatelessWidget {
  const NavigationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _navButton(context, 'Dashboard', '/dashboard'),
        _navButton(context, 'Perfil', '/profile'),
        _navButton(context, 'Cartas', '/cards'),
        _navButton(context, 'Favoritos', '/favorites'),
        _navButton(context, 'Configurações', '/settings'),
      ],
    );
  }

  Widget _navButton(BuildContext context, String label, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4D4A84),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
