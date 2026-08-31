import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';

class PokeApiService {
  final String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<Pokemon>> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final url = Uri.parse(
      '$baseUrl/pokemon?limit=$limit&offset=$offset',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List results = data['results'];

      return results
          .map((pokemon) => Pokemon.fromJson(pokemon))
          .toList();
    }

    throw Exception('Erro ao carregar os Pokémon');
  }

  Future<PokemonDetails> getPokemonDetails(int id) async {
    final url = Uri.parse('$baseUrl/pokemon/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return PokemonDetails.fromJson(data);
    }

    throw Exception('Erro ao carregar os detalhes do Pokémon');
    }
}