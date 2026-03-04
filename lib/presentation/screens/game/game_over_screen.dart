import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  final String lobbyId;

  const GameOverScreen({super.key, required this.lobbyId});

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen> {
  bool _showRestart = false;
  bool _loading = false;

  Future<void> _restartGame() async {
    setState(() => _loading = true);
    try {
      await ref.read(lobbyServiceProvider).resetGame(widget.lobbyId);
      if (mounted) {
        context.go('/lobby/${widget.lobbyId}');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameStateAsync = ref.watch(gameStateProvider(widget.lobbyId));

    return Scaffold(
      body: gameStateAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (state) {
          if (state == null) return const SizedBox.shrink();

          final winner = state.lobby.winnerId;
          final isMafiaWin = winner == AppConstants.factionMafia;
          final isHost = state.currentPlayer?.userId == state.lobby.hostId;

          return Stack(
            children: [
              // Atmospheric background
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      isMafiaWin
                          ? const Color(0xFF1A0508)
                          : const Color(0xFF0A1208),
                      AppColors.background,
                    ],
                  ),
                ),
              ),

              // Particle overlay (simulated with dots)
              Positioned.fill(
                child: CustomPaint(
                  painter: _StarfieldPainter(
                      color: isMafiaWin ? AppColors.blood : AppColors.alive),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Winner emoji
                        Text(
                          isMafiaWin ? '🔪' : '⚖️',
                          style: const TextStyle(fontSize: 80),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.2, 0.2),
                              end: const Offset(1.0, 1.0),
                              duration: 800.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(duration: 400.ms),

                        const SizedBox(height: 24),

                        Text(
                          isMafiaWin ? 'MAFIA GEWINNT' : 'BÜRGER GEWINNEN',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: isMafiaWin
                                    ? AppColors.blood
                                    : AppColors.alive,
                              ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 12),

                        Text(
                          isMafiaWin
                              ? 'Die Mafia hat die Kontrolle übernommen.'
                              : 'Alle Mafia-Mitglieder wurden eliminiert.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 600.ms),

                        const OrnamentDivider(),

                        // Role reveal list
                        Text(
                          'ROLLENAUFLÖSUNG',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ).animate().fadeIn(delay: 700.ms),

                        const SizedBox(height: 16),

                        ...state.players.asMap().entries.map((entry) {
                          final player = entry.value;
                          final isMafia =
                              player.faction == AppConstants.factionMafia;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isMafia
                                  ? AppColors.blood.withOpacity(0.08)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isMafia
                                    ? AppColors.blood.withOpacity(0.3)
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(player.roleEmoji,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player.displayName,
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: player.alive
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted,
                                          decoration: player.alive
                                              ? null
                                              : TextDecoration.lineThrough,
                                        ),
                                      ),
                                      Text(
                                        player.roleDisplayName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isMafia
                                              ? AppColors.blood
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!player.alive)
                                  const Icon(Icons.close,
                                      color: AppColors.blood, size: 16),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(
                                  delay: Duration(
                                      milliseconds: 800 + entry.key * 80))
                              .slideX(begin: 0.15);
                        }),

                        const SizedBox(height: 40),

                        // Restart options
                        if (isHost) ...[
                          if (!_showRestart)
                            MafiaButton(
                              label: 'Neues Spiel',
                              isDestructive: true,
                              icon: Icons.refresh,
                              onPressed: () =>
                                  setState(() => _showRestart = true),
                            ).animate().fadeIn(delay: 1200.ms),
                          if (_showRestart) ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'NEUES SPIEL',
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  MafiaButton(
                                    label: 'Gleiche Spieler',
                                    isDestructive: true,
                                    isLoading: _loading,
                                    onPressed: _restartGame,
                                  ),
                                  const SizedBox(height: 10),
                                  MafiaButton(
                                    label: 'Zur Lobby (neue Spieler)',
                                    isOutlined: true,
                                    onPressed: () async {
                                      await ref
                                          .read(lobbyServiceProvider)
                                          .resetGame(widget.lobbyId);
                                      if (context.mounted) {
                                        context.go('/lobby/${widget.lobbyId}');
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton(
                                    onPressed: () =>
                                        setState(() => _showRestart = false),
                                    child: const Text('Abbrechen',
                                        style: TextStyle(
                                            color: AppColors.textMuted)),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn().slideY(begin: 0.2),
                          ],
                        ],

                        if (!isHost)
                          Text(
                            'Warte auf den Spielführer...',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ).animate().fadeIn(delay: 1200.ms),

                        const SizedBox(height: 24),

                        TextButton(
                          onPressed: () => context.go(AppRoutes.home),
                          child: const Text(
                            'Zur Startseite',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 14),
                          ),
                        ).animate().fadeIn(delay: 1400.ms),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Simple starfield background painter
class _StarfieldPainter extends CustomPainter {
  final Color color;

  _StarfieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.04);
    final positions = [
      Offset(0.1, 0.1),
      Offset(0.9, 0.15),
      Offset(0.3, 0.25),
      Offset(0.7, 0.05),
      Offset(0.5, 0.35),
      Offset(0.15, 0.6),
      Offset(0.85, 0.55),
      Offset(0.4, 0.8),
      Offset(0.6, 0.9),
      Offset(0.25, 0.92),
      Offset(0.75, 0.85),
      Offset(0.05, 0.45),
      Offset(0.95, 0.7),
      Offset(0.55, 0.15),
      Offset(0.2, 0.4),
    ];
    for (final pos in positions) {
      canvas.drawCircle(
        Offset(pos.dx * size.width, pos.dy * size.height),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
