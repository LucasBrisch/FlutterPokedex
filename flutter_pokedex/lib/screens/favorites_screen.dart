import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorite_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.watch<FavoriteProvider>();
    final favorites = favoriteProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'Nenhum Pokémon favoritado ainda.',
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final pokemon = favorites[index];

                return Semantics(
                  label: '${pokemon.upperName}, favorito',
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.network(
                              pokemon.imageUrl,
                              semanticLabel: 'Imagem de ${pokemon.upperName}',
                              fit: BoxFit.contain,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  semanticLabel: 'Imagem indisponível',
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
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}