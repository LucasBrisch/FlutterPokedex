import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';
import 'pokemon_details_screen.dart';
import 'favorites_screen.dart';
import 'captured_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final PokeApiService _pokeApiService = PokeApiService();

  List<Pokemon> _pokemonList = [];
  int _offset = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  Future<void> _loadPokemon() async {
    try {
      final pokemon = await _pokeApiService.getPokemonList(offset: _offset);

      setState(() {
        _pokemonList.addAll(pokemon);
        _offset += pokemon.length;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.star),
            tooltip: 'Ver favoritos',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CapturedScreen(),
                ),
              );
            },
            icon: const Icon(Icons.catching_pokemon),
            tooltip: 'Ver Pokémon capturados',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pokemonList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    itemBuilder: (context, index) {
                      final pokemon = _pokemonList[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PokemonDetailsScreen(
                                pokemon: pokemon,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    pokemon.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pokemon.upperName,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _isLoadingMore
                        ? null
                        : () {
                            setState(() {
                              _isLoadingMore = true;
                            });

                            _loadPokemon();
                          },
                    child: _isLoadingMore
                        ? const CircularProgressIndicator()
                        : const Text('Carregar Mais'),
                  ),
                ),
              ],
            ),
    );
  }
}
