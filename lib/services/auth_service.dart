import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

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

    // Supabase gibt user zurück auch wenn Email-Confirm aktiv ist
    final user = response.user;
    if (user == null) throw Exception('Registrierung fehlgeschlagen');

    // Session kann null sein wenn Email-Confirm aktiv → trotzdem kein Fehler
    // Profil wird per Trigger angelegt, kein manueller Insert nötig
    return _buildAppUser(user, displayName, false);
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

  Future<AppUser> signInAsGuest({required String displayName}) async {
    final response = await _client.auth.signInAnonymously();
    if (response.user == null) throw Exception('Gast-Login fehlgeschlagen');

    final userId = response.user!.id;

    // Profil direkt mit service_role-ähnlichem Ansatz: erst versuchen einzufügen
    // RLS erlaubt INSERT with check(true) nach unserem Fix
    try {
      await _client.from('profiles').upsert({
        'id': userId,
        'display_name': displayName,
        'is_guest': true,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    } catch (_) {
      // Falls Profil schon existiert (z.B. durch Trigger) → update
      try {
        await _client.from('profiles').update({
          'display_name': displayName,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      } catch (_) {
        // Profil konnte nicht gesetzt werden, aber Login trotzdem durchlassen
      }
    }

    return _buildAppUser(response.user!, displayName, true);
  }

  Future<AppUser?> fetchCurrentUser() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final profile = await _fetchProfile(user.id);
      final displayName = profile?['display_name'] as String? ??
          user.email?.split('@').first ??
          'Gast';
      final isGuest = profile?['is_guest'] as bool? ?? false;
      return _buildAppUser(user, displayName, isGuest);
    } catch (_) {
      return _buildAppUser(
        user,
        user.email?.split('@').first ?? 'Gast',
        false,
      );
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    try {
      final result = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return result;
    } catch (_) {
      return null;
    }
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
