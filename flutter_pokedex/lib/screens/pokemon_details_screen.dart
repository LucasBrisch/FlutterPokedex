import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';
import '../services/pokeapi_service.dart';

import 'package:provider/provider.dart';

import '../providers/captured_provider.dart';

import '../providers/favorite_provider.dart';

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
  bool _isUpdatingFavorite = false;
  bool _isUpdatingCaptured = false;

  @override
  void initState() {
    super.initState();

    _pokemonDetailsFuture = _pokeApiService.getPokemonDetails(
      widget.pokemon.id,
    );
  }

  void _retryLoadDetails() {
    setState(() {
      _pokemonDetailsFuture = _pokeApiService.getPokemonDetails(
        widget.pokemon.id,
      );
    });
  }

  Future<void> _toggleFavorite(
    FavoriteProvider favoriteProvider,
    bool isFavorite,
  ) async {
    setState(() {
      _isUpdatingFavorite = true;
    });

    try {
      if (isFavorite) {
        await favoriteProvider.removeFavorite(widget.pokemon);
      } else {
        await favoriteProvider.addFavorite(widget.pokemon);
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível atualizar os favoritos.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingFavorite = false;
        });
      }
    }
  }

  Future<void> _toggleCaptured(
    CapturedProvider capturedProvider,
    bool isCaptured,
  ) async {
    setState(() {
      _isUpdatingCaptured = true;
    });

    try {
      if (isCaptured) {
        await capturedProvider.releasePokemon(widget.pokemon);
      } else {
        await capturedProvider.capturePokemon(widget.pokemon);
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível atualizar os Pokémon capturados.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingCaptured = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemon.upperName),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              final isFavorite = favoriteProvider.isFavorite(
                widget.pokemon,
              );

              return IconButton(
                onPressed: _isUpdatingFavorite
                    ? null
                    : () => _toggleFavorite(favoriteProvider, isFavorite),
                icon: _isUpdatingFavorite
                    ? Semantics(
                        label: 'Atualizando favoritos',
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Icon(isFavorite ? Icons.star : Icons.star_border),
                tooltip: _isUpdatingFavorite
                    ? 'Atualizando favoritos'
                    : isFavorite
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
              );
            },
          ),

          Consumer<CapturedProvider>(
            builder: (context, capturedProvider, child) {
              final isCaptured = capturedProvider.isCaptured(
                widget.pokemon,
              );

              return IconButton(
                onPressed: _isUpdatingCaptured
                    ? null
                    : () => _toggleCaptured(capturedProvider, isCaptured),
                icon: _isUpdatingCaptured
                    ? Semantics(
                        label: 'Atualizando Pokémon capturados',
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Icon(
                        isCaptured
                            ? Icons.check_circle
                            : Icons.catching_pokemon,
                      ),
                tooltip: _isUpdatingCaptured
                    ? 'Atualizando Pokémon capturados'
                    : isCaptured
                    ? 'Marcar como não capturado'
                    : 'Marcar como capturado',
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<PokemonDetails>(
        future: _pokemonDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Semantics(
                label: 'Carregando detalhes do Pokémon',
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Não foi possível carregar os detalhes do Pokémon.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retryLoadDetails,
                    child: const Text('Tentar novamente'),
                  ),
                ],
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
                  semanticLabel: 'Imagem de ${pokemonDetails.upperName}',
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 250,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                          semanticLabel: 'Imagem indisponível',
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
    return Semantics(
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value),
            ],
          ),
        ),
      ),
    );
  }
}