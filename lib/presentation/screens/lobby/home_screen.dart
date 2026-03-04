import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserModelProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Atmospheric background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, -0.8),
                radius: 1.0,
                colors: [Color(0xFF150508), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MAFIA',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(color: AppColors.blood),
                          ),
                          userAsync.when(
                            data: (user) => Text(
                              user?.displayName ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => context.go(AppRoutes.profile),
                        icon: const Icon(Icons.person_outline,
                            color: AppColors.textSecondary, size: 22),
                        tooltip: 'Profil',
                      ),
                      IconButton(
                        onPressed: () async {
                          await ref.read(authServiceProvider).signOut();
                          if (context.mounted) context.go(AppRoutes.login);
                        },
                        icon: const Icon(Icons.logout,
                            color: AppColors.textSecondary, size: 22),
                        tooltip: 'Abmelden',
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.blood.withOpacity(0.08),
                            border: Border.all(
                              color: AppColors.blood.withOpacity(0.25),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text('🔪', style: TextStyle(fontSize: 52)),
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                              begin: const Offset(0.97, 0.97),
                              end: const Offset(1.03, 1.03),
                              duration: 2000.ms,
                              curve: Curves.easeInOut,
                            ),

                        const SizedBox(height: 48),

                        Text(
                          'WAS MÖCHTEST DU TUN?',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(letterSpacing: 3),
                        ).animate().fadeIn(delay: 100.ms),

                        const SizedBox(height: 24),

                        // Create Lobby
                        MafiaButton(
                          label: 'Neue Lobby erstellen',
                          icon: Icons.add,
                          isDestructive: true,
                          onPressed: () => context.go(AppRoutes.createLobby),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                        const SizedBox(height: 14),

                        // Join Lobby
                        MafiaButton(
                          label: 'Lobby beitreten',
                          icon: Icons.qr_code_scanner,
                          isOutlined: true,
                          onPressed: () => context.go(AppRoutes.joinLobby),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                        const SizedBox(height: 48),

                        // Game modes info
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SPIELMODI',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: AppColors.gold),
                              ),
                              const SizedBox(height: 14),
                              _modeRow(
                                context,
                                icon: Icons.smartphone,
                                title: 'Ein-Gerät-Modus',
                                desc: 'Gerät wird herumgereicht',
                              ),
                              const SizedBox(height: 10),
                              _modeRow(
                                context,
                                icon: Icons.qr_code,
                                title: 'QR-Code-Modus',
                                desc: 'Jeder auf eigenem Gerät',
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms),
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

  Widget _modeRow(BuildContext context,
      {required IconData icon, required String title, required String desc}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
            Text(desc,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                )),
          ],
        ),
      ],
    );
  }
}
