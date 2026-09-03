import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pokemon.dart';

class FavoriteProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  final List<Pokemon> _favorites = [];

  List<Pokemon> get favorites => _favorites;

  Future<void> loadFavorites() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _favorites.clear();
      notifyListeners();
      return;
    }

    final response = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', user.id);

    _favorites.clear();

    for (final favorite in response) {
      _favorites.add(
        Pokemon(
          id: favorite['pokemon_id'] as int,
          name: favorite['pokemon_name'] as String,
          url: favorite['pokemon_url'] as String,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> addFavorite(Pokemon pokemon) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    if (isFavorite(pokemon)) {
      return;
    }

    await _supabase.from('favorites').insert({
      'user_id': user.id,
      'pokemon_id': pokemon.id,
      'pokemon_name': pokemon.name,
      'pokemon_url': pokemon.url,
    });

    _favorites.add(pokemon);

    notifyListeners();
  }

  Future<void> removeFavorite(Pokemon pokemon) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('pokemon_id', pokemon.id);

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