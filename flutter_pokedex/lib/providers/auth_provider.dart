import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get user => _supabase.auth.currentUser;

  bool get isAuthenticated => user != null;

  Future<String?> login(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'Ocorreu um erro ao fazer login.';
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'Ocorreu um erro ao criar a conta.';
    }
  }

  void notifyAuthChanged() {
    notifyListeners();
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}