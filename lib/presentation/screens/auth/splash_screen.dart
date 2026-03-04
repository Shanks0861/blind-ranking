// ─── SPLASH SCREEN ───────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/game_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      final auth = ref.read(authStateProvider);
      auth.when(
        data: (user) =>
            context.go(user != null ? AppRoutes.home : AppRoutes.login),
        loading: () {},
        error: (_, __) => context.go(AppRoutes.login),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for auth state to navigate early
    ref.listen(authStateProvider, (_, next) {
      next.whenData((user) {
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted)
            context.go(user != null ? AppRoutes.home : AppRoutes.login);
        });
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blood.withOpacity(0.15),
                border: Border.all(
                  color: AppColors.blood.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text('🔪', style: TextStyle(fontSize: 44)),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 28),
            Text(
              'MAFIA',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.blood,
                    letterSpacing: 8,
                  ),
            ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
            const SizedBox(height: 8),
            Text(
              'DAS SPIEL DER TÄUSCHUNG',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(letterSpacing: 4),
            ).animate().fadeIn(delay: 500.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
