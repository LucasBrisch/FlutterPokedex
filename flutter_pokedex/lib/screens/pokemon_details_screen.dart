import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';
import '../services/pokeapi_service.dart';

class PokemonDetailsScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailsScreen({
    super.key,
    required this.pokemon,
  });

  @override
  State<PokemonDetailsScreen> createState() => _PokemonDetailsScreenState();
}

class _PokemonDetailsScreenState extends State<PokemonDetailsScreen> {
  final PokeApiService _pokeApiService = PokeApiService();

  late Future<PokemonDetails> _pokemonDetailsFuture;

  @override
  void initState() {
    super.initState();

    _pokemonDetailsFuture = _pokeApiService.getPokemonDetails(
      widget.pokemon.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemon.upperName),
      ),
      body: FutureBuilder<PokemonDetails>(
        future: _pokemonDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Não foi possível carregar os detalhes do Pokémon.',
              ),
            );
          }

          final pokemonDetails = snapshot.data;

          if (pokemonDetails == null) {
            return const Center(
              child: Text(
                'Nenhum detalhe encontrado.',
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Image.network(
                  pokemonDetails.imageUrl,
                  height: 250,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 250,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  pokemonDetails.upperName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                _buildDetail(
                  'Número',
                  '#${pokemonDetails.id}',
                ),
                _buildDetail(
                  'Tipos',
                  pokemonDetails.types.join(', '),
                ),
                _buildDetail(
                  'Altura',
                  '${pokemonDetails.height / 10} m',
                ),
                _buildDetail(
                  'Peso',
                  '${pokemonDetails.weight / 10} kg',
                ),
                _buildDetail(
                  'Habilidades',
                  pokemonDetails.abilities.join(', '),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}