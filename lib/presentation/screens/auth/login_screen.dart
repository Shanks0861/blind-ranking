import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithEmail(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          );
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('wrong-password') ||
        raw.contains('user-not-found') ||
        raw.contains('invalid-credential')) {
      return 'E-Mail oder Passwort falsch.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Zu viele Versuche. Bitte warte kurz.';
    }
    return 'Anmeldung fehlgeschlagen. Bitte versuche es erneut.';
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
                colors: [Color(0xFF1A0808), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'MAFIA',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(color: AppColors.blood),
                    ).animate().fadeIn(duration: 800.ms).scale(
                          begin: const Offset(0.8, 0.8),
                          duration: 800.ms,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 8),
                    Text(
                      'DAS SPIEL DER TÄUSCHUNG',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textMuted, letterSpacing: 4),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                    const SizedBox(height: 60),
                    Column(
                      children: [
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'E-Mail',
                            prefixIcon: Icon(Icons.mail_outline,
                                color: AppColors.textMuted, size: 20),
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: AppColors.textPrimary),
                          onSubmitted: (_) => _login(),
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
                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
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
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_outlined,
                                    color: AppColors.blood, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(
                                        color: AppColors.blood,
                                        fontSize: 13,
                                      )),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().shakeX(hz: 3),
                        ],
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.go(AppRoutes.forgotPassword),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Passwort vergessen?',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        MafiaButton(
                          label: 'Anmelden',
                          onPressed: _login,
                          isLoading: _loading,
                          isDestructive: true,
                        ).animate().fadeIn(delay: 600.ms),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.register),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Noch kein Konto? ',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Registrieren',
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 800.ms),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
