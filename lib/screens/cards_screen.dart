import 'package:flutter/material.dart';
import 'card_details_screen.dart';
import '../widgets/navbar.dart';
import '../models/plant_card.dart';
import '../../services/cards_service.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final CardsService _cardsService = CardsService();
  List<PlantCard> _cards = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cards = await _cardsService.loadCards();
      if (mounted) {
        setState(() {
          _cards = cards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar cards: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showUnlockDialog(PlantCard card) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_open, color: Colors.amber),
            const SizedBox(width: 8),
            const Text(
              'Desbloquear Card',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja desbloquear o card de ${card.name}?',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              card.summary,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              await _cardsService.unlockCard(card.id);
              await _loadCards();
              if (context.mounted) {
                Navigator.pop(context);
                _showCardDetails(card.id);
              }
            },
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );
  }

  void _showCardDetails(String cardId) {
    final card = _cardsService.getCardById(cardId);
    if (card != null && card.unlocked) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CardDetailPage(card: card),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: MicroGardenAppBar(
        titleWidget: Row(
          children: [
            const Text('CARDS', style: TextStyle(color: Colors.yellow)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: Text(
                '${_cardsService.getUnlockedCount()}/${_cardsService.getTotalCount()}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCards,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Header with progress
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Coleção de Plantas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(_cardsService.getUnlockedCount() / _cardsService.getTotalCount() * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _cardsService.getUnlockedCount() /
                                _cardsService.getTotalCount(),
                            backgroundColor: Colors.grey[700],
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.amber),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),

                    // Cards Grid
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: GridView.builder(
                          itemCount: _cards.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          itemBuilder: (context, index) {
                            final card = _cards[index];
                            return _buildCardTile(card);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCardTile(PlantCard card) {
    return GestureDetector(
      onTap: () {
        if (card.unlocked) {
          _showCardDetails(card.id);
        } else {
          _showUnlockDialog(card);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: card.unlocked ? Colors.grey[800] : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: card.unlocked ? Colors.amber : Colors.grey[700]!,
            width: card.unlocked ? 2 : 1,
          ),
          boxShadow: card.unlocked
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha:0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Card Image or Lock Icon
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: card.unlocked
                    ? Image.asset(
                        card.image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.eco,
                            size: 48,
                            color: Colors.green,
                          );
                        },
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 0.2,
                            child: Image.asset(
                              card.image,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.eco,
                                  size: 48,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                          const Icon(
                            Icons.lock,
                            size: 36,
                            color: Colors.grey,
                          ),
                        ],
                      ),
              ),
            ),

            // Card Name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: card.unlocked
                    ? Colors.amber.withValues(alpha:0.3)
                    : Colors.grey[850],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                card.unlocked ? card.name : '???',
                style: TextStyle(
                  color: card.unlocked ? Colors.white : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}