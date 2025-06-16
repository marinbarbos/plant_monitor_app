import 'package:flutter/material.dart';
import 'card_details_screen.dart';
import '../widgets/navbar.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy cards data
    final List<Map<String, String>> cards = List.generate(20, (index) {
      return {
        'title': 'Card ${index + 1}',
        'image': '', // You can add image URLs or asset paths here
        'summary': 'Breves detalhes e conclusao',
        'description':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque faucibus ex sapien...',
      };
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: const MicroGardenAppBar(
        titleWidget: const Text(
          'CARDS',
          style: TextStyle(color: Colors.yellow),
        ),
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardDetailPage(card: cards[index]),
                  ),
                );
              },
              child: Container(
                color: Colors.grey,
                child: const Center(child: Icon(Icons.eco_outlined)),
              ),
            );
          },
        ),
      ),
    );
  }
}
