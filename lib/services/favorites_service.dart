import 'package:plant_monitor_1/services/achievement_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant_card.dart';
import 'cards_service.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  static const String _favoritesKey = 'favorite_cards';
  static const int maxFavorites = 4;

  final CardsService _cardsService = CardsService();

  /// Get favorite card IDs from SharedPreferences
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesList = prefs.getStringList(_favoritesKey);
    return favoritesList ?? [];
  }

  /// Get favorite cards as PlantCard objects
  Future<List<PlantCard>> getFavoriteCards() async {
    final favoriteIds = await getFavoriteIds();
    final List<PlantCard> favoriteCards = [];

    for (final id in favoriteIds) {
      final card = _cardsService.getCardById(id);
      if (card != null) {
        favoriteCards.add(card);
      }
    }

    return favoriteCards;
  }

  /// Add a card to favorites
  Future<bool> addFavorite(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = await getFavoriteIds();

      // Check if already in favorites
      if (favoriteIds.contains(cardId)) {
        return false;
      }

      // Check if we've reached the limit
      if (favoriteIds.length >= maxFavorites) {
        return false;
      }

      // Add to favorites
      favoriteIds.add(cardId);
      AchievementTracker().onFavoriteAdded(_instance.getFavoriteCount() as int);
      
      await prefs.setStringList(_favoritesKey, favoriteIds);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove a card from favorites
  Future<bool> removeFavorite(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = await getFavoriteIds();

      if (!favoriteIds.contains(cardId)) {
        return false;
      }

      favoriteIds.remove(cardId);
      await prefs.setStringList(_favoritesKey, favoriteIds);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String cardId) async {
    final favoriteIds = await getFavoriteIds();
    
    if (favoriteIds.contains(cardId)) {
      return await removeFavorite(cardId);
    } else {
      return await addFavorite(cardId);
    }
  }

  /// Check if a card is in favorites
  Future<bool> isFavorite(String cardId) async {
    final favoriteIds = await getFavoriteIds();
    return favoriteIds.contains(cardId);
  }

  /// Get count of favorites
  Future<int> getFavoriteCount() async {
    final favoriteIds = await getFavoriteIds();
    return favoriteIds.length;
  }

  /// Check if favorites are full
  Future<bool> isFull() async {
    final count = await getFavoriteCount();
    return count >= maxFavorites;
  }

  /// Get remaining slots
  Future<int> getRemainingSlots() async {
    final count = await getFavoriteCount();
    return maxFavorites - count;
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }
}
