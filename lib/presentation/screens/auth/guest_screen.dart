import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/firebase_service.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class GuestScreen extends ConsumerStatefulWidget {
  const GuestScreen({super.key});

  @override
  ConsumerState<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends ConsumerState<GuestScreen> {
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinAsGuest() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Bitte gib einen Namen ein.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInAnonymously(_nameCtrl.text.trim());
      if (user == null) throw Exception('Anonyme Anmeldung fehlgeschlagen');
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
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
                radius: 1.3,
                colors: [Color(0xFF0A0A1A), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go(AppRoutes.login),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppColors.textSecondary, size: 20),
                      ),
                      Text('GASTZUGANG',
                          style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Text('🚪', style: TextStyle(fontSize: 64))
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(begin: const Offset(0.5, 0.5)),

                          const SizedBox(height: 24),

                          Text(
                            'Als Gast spielen',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ).animate().fadeIn(delay: 200.ms),

                          const SizedBox(height: 8),

                          Text(
                            'Kein Konto nötig — gib einfach deinen Namen ein.',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 300.ms),

                          const OrnamentDivider(),

                          // Name field
                          TextField(
                            controller: _nameCtrl,
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                            maxLength: 20,
                            decoration: const InputDecoration(
                              labelText: 'Dein Spielername',
                              prefixIcon: Icon(Icons.person_outline,
                                  color: AppColors.textMuted, size: 20),
                              counterStyle:
                                  TextStyle(color: AppColors.textMuted),
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
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_outlined,
                                      color: AppColors.blood, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(_error!,
                                        style: const TextStyle(
                                            color: AppColors.blood,
                                            fontSize: 13)),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn().shakeX(),
                          ],

                          const SizedBox(height: 24),

                          MafiaButton(
                            label: 'Als Gast spielen',
                            isDestructive: true,
                            isLoading: _loading,
                            onPressed: _joinAsGuest,
                          ).animate().fadeIn(delay: 500.ms),

                          const SizedBox(height: 24),

                          TextButton(
                            onPressed: () => context.go(AppRoutes.login),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Konto erstellen? ',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14),
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
                          ).animate().fadeIn(delay: 700.ms),
                        ],
                      ),
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
