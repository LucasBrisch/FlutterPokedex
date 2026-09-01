import '../models/pokemon.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pokemon.dart';

class FavoriteProvider extends ChangeNotifier {
  static const String _favoritesKey = 'favorite_pokemon';
  final List<Pokemon> _favorites = [];

  List<Pokemon> get favorites => _favorites;

  Future<void> loadFavorites() async {
    final preferences = await SharedPreferences.getInstance();

    final favoritesJson = preferences.getStringList(
      _favoritesKey,
    );

    if (favoritesJson == null) {
      return;
    }

    _favorites.clear();

    for (final pokemonJson in favoritesJson) {
      final data = jsonDecode(pokemonJson);

      _favorites.add(
        Pokemon.fromStorageJson(data),
      );
    }

    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final preferences = await SharedPreferences.getInstance();

    final favoritesJson = _favorites
        .map(
          (pokemon) => jsonEncode(
            pokemon.toJson(),
          ),
        )
        .toList();

    await preferences.setStringList(
      _favoritesKey,
      favoritesJson,
    );
  }

  Future<void> addFavorite(Pokemon pokemon) async {
    _favorites.add(pokemon);

    await _saveFavorites();

    notifyListeners();
  }

  Future<void> removeFavorite(Pokemon pokemon) async {
    _favorites.removeWhere(
      (favorite) => favorite.id == pokemon.id,
    );

    await _saveFavorites();

    notifyListeners();
  }

  bool isFavorite(Pokemon pokemon) {
    return _favorites.any(
      (favorite) => favorite.id == pokemon.id,
    );
  }
}