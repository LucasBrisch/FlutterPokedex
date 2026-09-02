import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pokemon.dart';

class CapturedProvider extends ChangeNotifier {
  static const String _capturedKey = 'captured_pokemon';

  final List<Pokemon> _captured = [];

  List<Pokemon> get captured => _captured;

  Future<void> loadCaptured() async {
    final preferences = await SharedPreferences.getInstance();

    final capturedJson = preferences.getStringList(
      _capturedKey,
    );

    if (capturedJson == null) {
      return;
    }

    _captured.clear();

    for (final pokemonJson in capturedJson) {
      final data = jsonDecode(pokemonJson);

      _captured.add(
        Pokemon.fromStorageJson(data),
      );
    }

    notifyListeners();
  }

  Future<void> _saveCaptured() async {
    final preferences = await SharedPreferences.getInstance();

    final capturedJson = _captured
        .map(
          (pokemon) => jsonEncode(
            pokemon.toJson(),
          ),
        )
        .toList();

    await preferences.setStringList(
      _capturedKey,
      capturedJson,
    );
  }

  Future<void> capturePokemon(Pokemon pokemon) async {
    _captured.add(pokemon);

    await _saveCaptured();

    notifyListeners();
  }

  Future<void> releasePokemon(Pokemon pokemon) async {
    _captured.removeWhere(
      (captured) => captured.id == pokemon.id,
    );

    await _saveCaptured();

    notifyListeners();
  }

  bool isCaptured(Pokemon pokemon) {
    return _captured.any(
      (captured) => captured.id == pokemon.id,
    );
  }
}