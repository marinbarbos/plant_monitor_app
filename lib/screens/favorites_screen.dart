import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example dummy data (replace with real logic or state management later)
    final favorites = [
      {
        'type': 'achievement',
        'title': 'Primeira Colheita',
        'description': 'Você colheu sua primeira microgreen!',
      },
      {'type': 'card', 'title': 'Rabanete', 'image': 'assets/cards/radish.png'},
    ];

    return Scaffold(
      appBar: const MicroGardenAppBar(
        titleWidget: Text('FAVORITES', style: TextStyle(color: Colors.yellow)),
        showBackButton: true,
      ),
      backgroundColor: const Color(0xFF2C2C2C),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final item = favorites[index];
          return GestureDetector(
            onTap: () {
              if (item['type'] == 'card') {
                Navigator.pushNamed(context, '/cardDetails', arguments: item);
              } else {
                // Could use a separate achievement detail screen if needed
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(item['title'] ?? ''),
                    content: Text(item['description'] ?? ''),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fechar'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amberAccent, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item['type'] == 'card')
                    Image.asset(item['image'] ?? '', height: 80)
                  else
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 60,
                    ),
                  const SizedBox(height: 10),
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (item['type'] == 'achievement')
                    Text(
                      item['description'] ?? '',
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
