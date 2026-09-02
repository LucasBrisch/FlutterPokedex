import 'package:flutter/material.dart';
import 'screens/catalog_screen.dart';
import 'package:provider/provider.dart';
import 'providers/captured_provider.dart';
import 'providers/favorite_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final favoriteProvider = FavoriteProvider();
  final capturedProvider = CapturedProvider();

  await favoriteProvider.loadFavorites();
  await capturedProvider.loadCaptured();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: favoriteProvider,
        ),
        ChangeNotifierProvider.value(
          value: capturedProvider,
        ),
      ],
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