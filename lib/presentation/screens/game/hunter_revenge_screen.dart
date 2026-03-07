import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class HunterRevengeScreen extends ConsumerStatefulWidget {
  final String lobbyId;
  const HunterRevengeScreen({super.key, required this.lobbyId});

  @override
  ConsumerState<HunterRevengeScreen> createState() =>
      _HunterRevengeScreenState();
}

class _HunterRevengeScreenState extends ConsumerState<HunterRevengeScreen> {
  bool _showIntro = true;
  String? _selectedTarget;
  bool _loading = false;

  Future<void> _confirmRevenge() async {
    if (_selectedTarget == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(lobbyServiceProvider).hunterRevenge(
            widget.lobbyId,
            _selectedTarget!,
          );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameStateAsync = ref.watch(gameStateProvider(widget.lobbyId));

    // Navigate when phase changes away from hunter_revenge
    ref.listen(gameStateProvider(widget.lobbyId), (_, next) {
      next.whenData((state) {
        if (state == null) return;
        switch (state.lobby.phase) {
          case AppConstants.phaseEvaluation:
            context.go('/game/${widget.lobbyId}');
          case AppConstants.phaseGameOver:
            context.go('/gameover/${widget.lobbyId}');
          case AppConstants.phaseSetup:
            context.go('/lobby/${widget.lobbyId}');
        }
      });
    });

    if (_showIntro) {
      return _buildIntro();
    }

    return gameStateAsync.when(
      loading: () => const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.hunterLight)),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Fehler: $e'))),
      data: (state) {
        if (state == null) return const SizedBox.shrink();

        final hunterTargetId = state.lobby.hunterTargetId;
        final hunter = state.players.firstWhere(
          (p) => p.playerId == hunterTargetId,
          orElse: () => state.players.first,
        );
        final isHunterDevice = state.currentPlayer?.playerId == hunterTargetId;

        // Alive players excluding the hunter
        final targets = state.alivePlayers
            .where((p) => p.playerId != hunterTargetId)
            .toList();

        return Scaffold(
          body: Stack(
            children: [
              // Atmospheric background — hunter orange/gold
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 1.5,
                    colors: [
                      AppColors.hunterLight.withOpacity(0.12),
                      AppColors.background,
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      const Text('🏹', style: TextStyle(fontSize: 56))
                          .animate()
                          .fadeIn()
                          .scale(begin: const Offset(0.4, 0.4)),
                      const SizedBox(height: 16),
                      Text(
                        'DER JÄGER SCHLÄGT ZU',
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 11,
                          letterSpacing: 5,
                          color: AppColors.hunterLight.withOpacity(0.7),
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 10),
                      Text(
                        hunter.displayName,
                        style: const TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.hunterLight,
                          letterSpacing: 2,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 6),
                      Text(
                        'wurde eliminiert — doch er nimmt jemanden mit.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 600.ms),
                      const OrnamentDivider(),
                      if (isHunterDevice || true) ...[
                        // show to all, host confirms
                        Text(
                          isHunterDevice
                              ? 'Wähle dein Opfer, Jäger.'
                              : 'Gib das Gerät an ${hunter.displayName}.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 700.ms),

                        const SizedBox(height: 16),

                        Expanded(
                          child: ListView.separated(
                            itemCount: targets.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final t = targets[i];
                              final selected = _selectedTarget == t.playerId;
                              return GestureDetector(
                                onTap: () => setState(
                                    () => _selectedTarget = t.playerId),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.hunterLight.withOpacity(0.1)
                                        : AppColors.card,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.hunterLight
                                          : AppColors.border,
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        selected ? '🎯' : '👤',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        t.displayName,
                                        style: TextStyle(
                                          fontFamily: 'Cinzel',
                                          fontSize: 18,
                                          color: selected
                                              ? AppColors.hunterLight
                                              : AppColors.textPrimary,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: (700 + i * 60).ms)
                                  .slideX(begin: 0.1);
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        MafiaButton(
                          label: _selectedTarget == null
                              ? 'Wähle ein Opfer'
                              : 'Jetzt eliminieren 🏹',
                          isDestructive: true,
                          isLoading: _loading,
                          onPressed:
                              _selectedTarget != null ? _confirmRevenge : null,
                        ).animate().fadeIn(delay: 900.ms),

                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIntro() {
    return GestureDetector(
      onTap: () => setState(() => _showIntro = false),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.5,
                  colors: [
                    AppColors.hunterLight.withOpacity(0.15),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏹', style: TextStyle(fontSize: 72))
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.3, 0.3)),
                    const SizedBox(height: 32),
                    Text(
                      'DER JÄGER',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 11,
                        letterSpacing: 6,
                        color: AppColors.hunterLight.withOpacity(0.6),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 16),
                    Text(
                      'fällt — doch nicht allein.',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.hunterLight,
                        letterSpacing: 1,
                        shadows: [
                          Shadow(
                            color: AppColors.hunterLight.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 40,
                            height: 1,
                            color: AppColors.hunterLight.withOpacity(0.3)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('✦',
                              style: TextStyle(
                                  color: AppColors.hunterLight.withOpacity(0.4),
                                  fontSize: 10)),
                        ),
                        Container(
                            width: 40,
                            height: 1,
                            color: AppColors.hunterLight.withOpacity(0.3)),
                      ],
                    ).animate().fadeIn(delay: 800.ms),
                    const SizedBox(height: 24),
                    Text(
                      'Der Jäger wurde getroffen.\nDoch er hat noch einen letzten Schuss.\nWen trifft sein Pfeil?',
                      style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.9,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 900.ms),
                    const SizedBox(height: 48),
                    Text(
                      'Tippe um fortzufahren',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted.withOpacity(0.5),
                        letterSpacing: 2,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .fadeIn(delay: 1500.ms, duration: 700.ms)
                        .then()
                        .fadeOut(duration: 700.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
