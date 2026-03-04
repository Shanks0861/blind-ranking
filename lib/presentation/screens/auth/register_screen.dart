import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Bitte gib deinen Namen ein.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).registerWithEmail(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
            _nameCtrl.text.trim(),
          );
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) {
      return 'Diese E-Mail wird bereits verwendet.';
    }
    if (raw.contains('weak-password')) {
      return 'Passwort zu schwach. Mindestens 6 Zeichen.';
    }
    if (raw.contains('invalid-email')) return 'Ungültige E-Mail-Adresse.';
    return 'Registrierung fehlgeschlagen.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [Color(0xFF0A0A1A), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.go(AppRoutes.login),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text('KONTO ERSTELLEN',
                                style:
                                    Theme.of(context).textTheme.headlineLarge)
                            .animate()
                            .fadeIn(duration: 500.ms),
                        const SizedBox(height: 6),
                        Text(
                          'Tritt dem Spiel der Täuschung bei',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 40),
                        TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Anzeigename',
                            prefixIcon: Icon(Icons.person_outline,
                                color: AppColors.textMuted, size: 20),
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'E-Mail',
                            prefixIcon: Icon(Icons.mail_outline,
                                color: AppColors.textMuted, size: 20),
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: AppColors.textPrimary),
                          onSubmitted: (_) => _register(),
                          decoration: InputDecoration(
                            labelText: 'Passwort',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.textMuted, size: 20),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.blood.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: AppColors.blood.withOpacity(0.4)),
                            ),
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: AppColors.blood, fontSize: 13)),
                          ).animate().fadeIn().shakeX(),
                        ],
                        const SizedBox(height: 28),
                        MafiaButton(
                          label: 'Registrieren',
                          onPressed: _register,
                          isLoading: _loading,
                          isDestructive: true,
                        ).animate().fadeIn(delay: 500.ms),
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: () => context.go(AppRoutes.login),
                            child: const Text(
                              'Bereits registriert? Anmelden',
                              style: TextStyle(
                                  color: AppColors.gold, fontSize: 14),
                            ),
                          ),
                        ).animate().fadeIn(delay: 600.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
