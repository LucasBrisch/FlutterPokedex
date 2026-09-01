import 'package:flutter/material.dart';

import '../models/pokemon.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Pokemon> _favorites = [];

  List<Pokemon> get favorites => _favorites;

  void addFavorite(Pokemon pokemon) {
    _favorites.add(pokemon);
    notifyListeners();
  }

  void removeFavorite(Pokemon pokemon) {
    _favorites.removeWhere(
      (favorite) => favorite.id == pokemon.id,
    );

    notifyListeners();
  }

  bool isFavorite(Pokemon pokemon) {
    return _favorites.any(
      (favorite) => favorite.id == pokemon.id,
    );
  }
}