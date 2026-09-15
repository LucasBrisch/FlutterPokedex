import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorite_provider.dart';
import '../providers/captured_provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha e-mail e senha.')));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final favoriteProvider = context.read<FavoriteProvider>();
    final capturedProvider = context.read<CapturedProvider>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _loading = true;
    });

    final error = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _loading = false;
      });

      messenger.showSnackBar(SnackBar(content: Text(error)));

      return;
    }

    var synchronizationFailed = false;

    try {
      await favoriteProvider.loadFavorites();
      await capturedProvider.loadCaptured();
    } catch (_) {
      synchronizationFailed = true;
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    if (synchronizationFailed) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Login concluído, mas não foi possível sincronizar seus dados.',
          ),
        ),
      );
    }

    authProvider.notifyAuthChanged();
  }

  Future<void> _register() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha e-mail e senha.'),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final error = await context.read<AuthProvider>().register(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conta criada com sucesso! Agora faça login.'),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.catching_pokemon,
                    size: 80,
                    semanticLabel: 'Pokébola',
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Pokédex',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  ),

                  const SizedBox(height: 32),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? Semantics(
                              label: 'Fazendo login',
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Entrar'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _loading ? null : _register,
                    child: const Text('Criar conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}