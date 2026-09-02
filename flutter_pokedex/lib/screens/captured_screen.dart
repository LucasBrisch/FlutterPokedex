import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/captured_provider.dart';

class CapturedScreen extends StatelessWidget {
  const CapturedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final capturedProvider = context.watch<CapturedProvider>();
    final captured = capturedProvider.captured;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Capturados'),
      ),
      body: captured.isEmpty
          ? const Center(
              child: Text(
                'Nenhum Pokémon capturado ainda.',
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: captured.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final pokemon = captured[index];

                return Card(
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
                              return const Icon(
                                Icons.image_not_supported,
                                size: 48,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pokemon.upperName,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}