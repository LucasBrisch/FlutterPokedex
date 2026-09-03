import 'package:flutter/material.dart';
import 'screens/catalog_screen.dart';
import 'package:provider/provider.dart';
import 'providers/captured_provider.dart';
import 'providers/favorite_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://igsnfvbaoixqerefkxqv.supabase.co',
    publishableKey: 'sb_publishable_fgCfP9s2deSWWQ7RvFmu0Q_nLjScrNU',
  );

  final favoriteProvider = FavoriteProvider();
  final capturedProvider = CapturedProvider();

  if (Supabase.instance.client.auth.currentSession != null) {
    await favoriteProvider.loadFavorites();
    await capturedProvider.loadCaptured();
}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider.value(
          value: favoriteProvider,
        ),
        ChangeNotifierProvider.value(
          value: capturedProvider,
        ),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pokédex',
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAuthenticated) {
            return const CatalogScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}