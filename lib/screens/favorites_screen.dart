import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../models/plant_card.dart';
import '../services/favorites_service.dart';
import '../services/cards_service.dart';
import 'card_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final CardsService _cardsService = CardsService();
  List<PlantCard> _favoriteCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      // Ensure cards are loaded first
      await _cardsService.loadCards();
      
      final favorites = await _favoritesService.getFavoriteCards();
      if (mounted) {
        setState(() {
          _favoriteCards = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeFavorite(String cardId) async {
    await _favoritesService.removeFavorite(cardId);
    await _loadFavorites();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removido dos favoritos'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _openCardDetails(PlantCard card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardDetailPage(card: card),
      ),
    ).then((_) => _loadFavorites()); // Refresh when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MicroGardenAppBar(
        titleWidget: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.pink, size: 24),
            const SizedBox(width: 8),
            const Text('FAVORITOS', style: TextStyle(color: Colors.pink)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink, width: 1),
              ),
              child: Text(
                '${_favoriteCards.length}/4',
                style: const TextStyle(
                  color: Colors.pink,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        showBackButton: true,
      ),
      backgroundColor: const Color(0xFF2C2C2C),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteCards.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum Favorito',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Adicione até 4 cards favoritos para acesso rápido!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/cards').then((_) => _loadFavorites());
              },
              icon: const Icon(Icons.view_module),
              label: const Text('Ir para Cards'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    // Create a list of 4 slots
    final List<Widget> slots = [];
    
    for (int i = 0; i < 4; i++) {
      if (i < _favoriteCards.length) {
        // Filled slot with favorite card
        slots.add(_buildFavoriteCard(_favoriteCards[i]));
      } else {
        // Empty slot
        slots.add(_buildEmptySlot(i + 1));
      }
    }

    return Column(
      children: [
        // Info banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.pink.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.pink.withValues(alpha:0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.pink, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Toque na estrela nos cards para adicionar aos favoritos',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Favorites grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: slots,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteCard(PlantCard card) {
    return GestureDetector(
      onTap: () => _openCardDetails(card),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.pink, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha:0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Card content
            Column(
              children: [
                // Image
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      card.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.eco,
                          size: 64,
                          color: Colors.green,
                        );
                      },
                    ),
                  ),
                ),
                // Name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink.withValues(alpha:0.2),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        card.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.growthTime,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Remove button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removeFavorite(card.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            // Favorite star indicator
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha:0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot(int slotNumber) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/cards').then((_) => _loadFavorites());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[700]!, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 12),
            Text(
              'Slot $slotNumber',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vazio',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}