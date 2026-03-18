import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Email & Passwort Login ──────────────────────────────────────────────────

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    if (response.user == null) throw Exception('Registrierung fehlgeschlagen');

    await _upsertProfile(
      userId: response.user!.id,
      displayName: displayName,
      email: email,
      isGuest: false,
    );

    return _buildAppUser(response.user!, displayName, false);
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) throw Exception('Login fehlgeschlagen');

    final profile = await _fetchProfile(response.user!.id);
    return _buildAppUser(
      response.user!,
      profile?['display_name'] as String? ?? email.split('@').first,
      false,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ── Anonymer / Gast Login ───────────────────────────────────────────────────

  Future<AppUser> signInAsGuest({required String displayName}) async {
    final response = await _client.auth.signInAnonymously();

    if (response.user == null) throw Exception('Gast-Login fehlgeschlagen');

    await _upsertProfile(
      userId: response.user!.id,
      displayName: displayName,
      isGuest: true,
    );

    return _buildAppUser(response.user!, displayName, true);
  }

  // ── Profil Abruf ───────────────────────────────────────────────────────────

  Future<AppUser?> fetchCurrentUser() async {
    final user = currentUser;
    if (user == null) return null;

    final profile = await _fetchProfile(user.id);
    final displayName =
        profile?['display_name'] as String? ??
        user.email?.split('@').first ??
        'Gast';
    final isGuest = profile?['is_guest'] as bool? ?? false;

    return _buildAppUser(user, displayName, isGuest);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  Future<void> _upsertProfile({
    required String userId,
    required String displayName,
    String? email,
    required bool isGuest,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'display_name': displayName,
      'email': email,
      'is_guest': isGuest,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    final result = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return result;
  }

  AppUser _buildAppUser(User user, String displayName, bool isGuest) {
    return AppUser(
      id: user.id,
      email: user.email,
      displayName: displayName,
      isGuest: isGuest,
    );
  }
}
