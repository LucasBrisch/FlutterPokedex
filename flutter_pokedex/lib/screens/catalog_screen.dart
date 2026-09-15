import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';
import 'pokemon_details_screen.dart';
import 'favorites_screen.dart';
import 'captured_screen.dart';
import '../providers/auth_provider.dart';

import 'package:provider/provider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final PokeApiService _pokeApiService = PokeApiService();
  final TextEditingController _searchController = TextEditingController();

  final List<Pokemon> _pokemonList = [];
  int _offset = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  String? _catalogError;

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  Future<void> _loadPokemon() async {
    final isInitialLoad = _pokemonList.isEmpty;

    try {
      final pokemon = await _pokeApiService.getPokemonList(offset: _offset);

      if (!mounted) return;

      setState(() {
        _pokemonList.addAll(pokemon);
        _offset += pokemon.length;
        _isLoading = false;
        _isLoadingMore = false;
        _catalogError = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        if (isInitialLoad) {
          _catalogError = 'Não foi possível carregar o catálogo.';
        }
      });

      if (!isInitialLoad) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível carregar mais Pokémon.'),
          ),
        );
      }
    }
  }

  void _retryInitialLoad() {
    setState(() {
      _isLoading = true;
      _catalogError = null;
    });

    _loadPokemon();
  }

  Future<void> _searchPokemon() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome ou número de um Pokémon.'),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final pokemon = await _pokeApiService.searchPokemon(query);

      if (!mounted) return;

      if (pokemon == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pokémon não encontrado.')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PokemonDetailsScreen(pokemon: pokemon),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível buscar o Pokémon. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                MaterialPageRoute(builder: (context) => const CapturedScreen()),
              );
            },
            icon: const Icon(Icons.catching_pokemon),
            tooltip: 'Ver Pokémon capturados',
          ),
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  enabled: !_isSearching,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchPokemon(),
                  decoration: const InputDecoration(
                    labelText: 'Buscar Pokémon',
                    hintText: 'Nome ou número',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchPokemon,
                    child: _isSearching
                        ? Semantics(
                            label: 'Buscando Pokémon',
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Text('Buscar'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Semantics(
                      label: 'Carregando catálogo',
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _catalogError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_catalogError!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _retryInitialLoad,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
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

                      return Semantics(
                        button: true,
                        label: 'Ver detalhes de ${pokemon.upperName}',
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PokemonDetailsScreen(pokemon: pokemon),
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
                                      semanticLabel:
                                          'Imagem de ${pokemon.upperName}',
                                      fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 48,
                                                semanticLabel:
                                                    'Imagem indisponível',
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    pokemon.upperName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (!_isLoading && _catalogError == null)
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
                    ? Semantics(
                        label: 'Carregando mais Pokémon',
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Carregar Mais'),
              ),
            ),
        ],
      ),
    );
  }
}
