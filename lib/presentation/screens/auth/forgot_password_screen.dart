import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Bitte gib deine E-Mail-Adresse ein.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailCtrl.text.trim(),
      );
      setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _error = 'Kein Konto mit dieser E-Mail gefunden.';
          case 'invalid-email':
            _error = 'Ungültige E-Mail-Adresse.';
          case 'too-many-requests':
            _error = 'Zu viele Versuche. Bitte warte kurz.';
          default:
            _error = 'Fehler beim Senden. Bitte versuche es erneut.';
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _sent
                        ? _buildSuccessView(context)
                        : _buildFormView(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('🔑', style: TextStyle(fontSize: 48))
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          'PASSWORT\nZURÜCKSETZEN',
          style: Theme.of(context).textTheme.displaySmall,
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          'Gib deine E-Mail-Adresse ein. Wir schicken dir einen Link zum Zurücksetzen.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 40),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.textPrimary),
          onSubmitted: (_) => _sendResetEmail(),
          decoration: const InputDecoration(
            labelText: 'E-Mail',
            prefixIcon:
                Icon(Icons.mail_outline, color: AppColors.textMuted, size: 20),
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blood.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.blood.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_outlined,
                    color: AppColors.blood, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_error!,
                      style: const TextStyle(
                          color: AppColors.blood, fontSize: 13)),
                ),
              ],
            ),
          ).animate().fadeIn().shakeX(),
        ],
        const SizedBox(height: 28),
        MafiaButton(
          label: 'Reset-Link senden',
          isDestructive: true,
          isLoading: _loading,
          onPressed: _sendResetEmail,
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text(
              'Zurück zum Login',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.alive.withOpacity(0.1),
            border:
                Border.all(color: AppColors.alive.withOpacity(0.4), width: 2),
          ),
          child: const Center(
            child: Text('✉️', style: TextStyle(fontSize: 44)),
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.3, 0.3),
              duration: 600.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 32),
        Text(
          'E-MAIL GESENDET',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(color: AppColors.alive),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 16),
        Text(
          'Wir haben einen Reset-Link an\n${_emailCtrl.text.trim()}\ngesendet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 12),
        Text(
          'Prüfe auch deinen Spam-Ordner.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 48),
        MafiaButton(
          label: 'Zurück zum Login',
          isDestructive: true,
          onPressed: () => context.go(AppRoutes.login),
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() {
            _sent = false;
            _emailCtrl.clear();
          }),
          child: const Text(
            'Andere E-Mail verwenden',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ).animate().fadeIn(delay: 700.ms),
      ],
    );
  }
}
