import 'package:flutter/material.dart';
import 'screens/catalog_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/favorite_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final favoriteProvider = FavoriteProvider();

  await favoriteProvider.loadFavorites();

  runApp(
    ChangeNotifierProvider.value(
      value: favoriteProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pokédex',
      home: const CatalogScreen(),
    );
  }
}