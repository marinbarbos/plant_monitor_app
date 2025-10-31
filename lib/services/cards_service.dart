import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant_card.dart';

class CardsService {
  static final CardsService _instance = CardsService._internal();
  factory CardsService() => _instance;
  CardsService._internal();

  List<PlantCard>? _cards;
  static const String _unlockedCardsKey = 'unlocked_cards';

  /// Load cards from JSON file
  Future<List<PlantCard>> loadCards() async {
    if (_cards != null) return _cards!;

    try {
      // Load JSON from assets
      final String jsonString =
          await rootBundle.loadString('assets/cards/cards_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> cardsJson = jsonData['cards'] as List;

      // Load unlocked status from SharedPreferences
      final Set<String> unlockedIds = await _getUnlockedCardIds();

      // Parse cards and set unlocked status
      _cards = cardsJson.map((cardJson) {
        final card = PlantCard.fromJson(cardJson as Map<String, dynamic>);
        return card.copyWith(unlocked: unlockedIds.contains(card.id));
      }).toList();

      return _cards!;
    } catch (e) {
      throw Exception('Failed to load cards: $e');
    }
  }

  /// Get unlocked card IDs from SharedPreferences
  Future<Set<String>> _getUnlockedCardIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? unlockedList = prefs.getStringList(_unlockedCardsKey);
    return unlockedList?.toSet() ?? {};
  }

  /// Unlock a card by ID
  Future<bool> unlockCard(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Set<String> unlockedIds = await _getUnlockedCardIds();
      
      if (unlockedIds.contains(cardId)) {
        return false; // Already unlocked
      }

      unlockedIds.add(cardId);
      await prefs.setStringList(_unlockedCardsKey, unlockedIds.toList());

      // Update cached cards
      if (_cards != null) {
        final index = _cards!.indexWhere((card) => card.id == cardId);
        if (index != -1) {
          _cards![index] = _cards![index].copyWith(unlocked: true);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Lock a card by ID (for testing purposes)
  Future<bool> lockCard(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Set<String> unlockedIds = await _getUnlockedCardIds();
      
      unlockedIds.remove(cardId);
      await prefs.setStringList(_unlockedCardsKey, unlockedIds.toList());

      // Update cached cards
      if (_cards != null) {
        final index = _cards!.indexWhere((card) => card.id == cardId);
        if (index != -1) {
          _cards![index] = _cards![index].copyWith(unlocked: false);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get card by ID
  PlantCard? getCardById(String cardId) {
    if (_cards == null) return null;
    try {
      return _cards!.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  /// Get all unlocked cards
  List<PlantCard> getUnlockedCards() {
    if (_cards == null) return [];
    return _cards!.where((card) => card.unlocked).toList();
  }

  /// Get all locked cards
  List<PlantCard> getLockedCards() {
    if (_cards == null) return [];
    return _cards!.where((card) => !card.unlocked).toList();
  }

  /// Get count of unlocked cards
  int getUnlockedCount() {
    if (_cards == null) return 0;
    return _cards!.where((card) => card.unlocked).length;
  }

  /// Get total count of cards
  int getTotalCount() {
    return _cards?.length ?? 0;
  }

  /// Check if a card is unlocked
  bool isCardUnlocked(String cardId) {
    final card = getCardById(cardId);
    return card?.unlocked ?? false;
  }

  /// Reset all cards (lock all)
  Future<void> resetAllCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_unlockedCardsKey);
    
    if (_cards != null) {
      _cards = _cards!.map((card) => card.copyWith(unlocked: false)).toList();
    }
  }

  /// Unlock all cards (for testing)
  Future<void> unlockAllCards() async {
    if (_cards == null) await loadCards();
    
    final allIds = _cards!.map((card) => card.id).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_unlockedCardsKey, allIds);
    
    _cards = _cards!.map((card) => card.copyWith(unlocked: true)).toList();
  }

  /// Refresh cards from storage
  Future<void> refreshCards() async {
    _cards = null;
    await loadCards();
  }
}