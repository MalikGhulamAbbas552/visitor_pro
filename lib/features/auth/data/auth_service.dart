import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  SupabaseClient get _supabase => Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Session? get currentSession =>
      _supabase.auth.currentSession;

  bool get isAuthenticated => currentSession != null;

  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': name.trim(),
      },
    );
  }

  Future<void> logout() {
    return _supabase.auth.signOut();
  }
}