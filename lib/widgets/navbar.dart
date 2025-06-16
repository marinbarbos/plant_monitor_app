import 'package:flutter/material.dart';

import 'package:plant_monitor_1/screens/dashboard_screen.dart';
import 'package:plant_monitor_1/screens/profile_screen.dart';
import 'package:plant_monitor_1/screens/favorites_screen.dart';
import 'package:plant_monitor_1/screens/cards_screen.dart';
import 'package:plant_monitor_1/screens/settings_screen.dart';

class MicroGardenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? titleWidget;
  final String? titleText;
  final bool showBackButton;

  const MicroGardenAppBar({
    Key? key,
    this.titleWidget,
    this.titleText,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black87,
      title: titleWidget ?? Text(titleText ?? "Micro Garden Dashboard"),
      automaticallyImplyLeading: showBackButton,
      actions: [
        IconButton(
          icon: const Icon(Icons.dataset),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.view_module),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CardsPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Alternative approach with callback functions for more flexibility
class MicroGardenAppBarWithCallbacks extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget? titleWidget;
  final String? titleText;
  final bool showBackButton;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onFavoritesPressed;
  final VoidCallback? onCardsPressed;
  final VoidCallback? onSettingsPressed;

  const MicroGardenAppBarWithCallbacks({
    Key? key,
    this.titleWidget,
    this.titleText,
    this.showBackButton = false,
    this.onProfilePressed,
    this.onFavoritesPressed,
    this.onCardsPressed,
    this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black87,
      title: titleWidget ?? Text(titleText ?? "Micro Garden Dashboard"),
      automaticallyImplyLeading: showBackButton,
      actions: [
        IconButton(
          icon: const Icon(Icons.dataset),
          onPressed:
              onProfilePressed ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardPage(),
                  ),
                );
              },
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed:
              onProfilePressed ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
        ),
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed:
              onFavoritesPressed ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
        ),
        IconButton(
          icon: const Icon(Icons.view_module),
          onPressed:
              onCardsPressed ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CardsPage()),
                );
              },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed:
              onSettingsPressed ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
