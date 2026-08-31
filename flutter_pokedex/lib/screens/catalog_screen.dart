import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final PokeApiService _pokeApiService = PokeApiService();

  late Future<List<Pokemon>> _pokemonFuture;

  @override
  void initState() {
    super.initState();

    _pokemonFuture = _pokeApiService.getPokemonList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), //Indicador de carregamento RF09
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Não foi possível carregar os Pokémon.',
              ),
            );
          }

          final pokemonList = snapshot.data ?? [];

          return ListView.builder(
            itemCount: pokemonList.length,
            itemBuilder: (context, index) {
              final pokemon = pokemonList[index];

              return ListTile(
                title: Text(pokemon.name),
              );
            },
          );
        },
      ),
    );
  }
}