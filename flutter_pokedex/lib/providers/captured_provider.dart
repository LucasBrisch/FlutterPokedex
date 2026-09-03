import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pokemon.dart';

class CapturedProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  final List<Pokemon> _captured = [];

  List<Pokemon> get captured => _captured;

  Future<void> loadCaptured() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _captured.clear();
      notifyListeners();
      return;
    }

    final response = await _supabase
        .from('captured_pokemon')
        .select()
        .eq('user_id', user.id);

    _captured.clear();

    for (final captured in response) {
      _captured.add(
        Pokemon(
          id: captured['pokemon_id'] as int,
          name: captured['pokemon_name'] as String,
          url: captured['pokemon_url'] as String,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> capturePokemon(Pokemon pokemon) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    if (isCaptured(pokemon)) {
      return;
    }

    await _supabase.from('captured_pokemon').insert({
      'user_id': user.id,
      'pokemon_id': pokemon.id,
      'pokemon_name': pokemon.name,
      'pokemon_url': pokemon.url,
    });

    _captured.add(pokemon);

    notifyListeners();
  }

  Future<void> releasePokemon(Pokemon pokemon) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    await _supabase
        .from('captured_pokemon')
        .delete()
        .eq('user_id', user.id)
        .eq('pokemon_id', pokemon.id);

    _captured.removeWhere(
      (captured) => captured.id == pokemon.id,
    );

    notifyListeners();
  }

  bool isCaptured(Pokemon pokemon) {
    return _captured.any(
      (captured) => captured.id == pokemon.id,
    );
  }
}