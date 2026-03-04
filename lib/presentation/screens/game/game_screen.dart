import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/game_models.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class GameScreen extends ConsumerWidget {
  final String lobbyId;

  const GameScreen({super.key, required this.lobbyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStateAsync = ref.watch(gameStateProvider(lobbyId));

    // Phase navigation
    ref.listen(gameStateProvider(lobbyId), (_, next) {
      next.whenData((state) {
        if (state == null) return;
        switch (state.lobby.phase) {
          case AppConstants.phaseVoting:
            context.go('/voting/$lobbyId');
          case AppConstants.phaseGameOver:
            context.go('/gameover/$lobbyId');
        }
      });
    });

    return Scaffold(
      body: gameStateAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (state) {
          if (state == null) return const SizedBox.shrink();

          final isHost = state.currentPlayer?.userId == state.lobby.hostId;
          final isEvaluation =
              state.lobby.phase == AppConstants.phaseEvaluation;

          return SafeArea(
            child: Column(
              children: [
                // Phase header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEvaluation ? 'AUSWERTUNG' : 'DISKUSSION',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: isEvaluation
                                        ? AppColors.blood
                                        : AppColors.gold,
                                  ),
                            ),
                            Text(
                              '${state.alivePlayers.length} Spieler am Leben',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      // Mafia vs Citizens counter
                      _factionCounter(context, state),
                    ],
                  ),
                ),

                // Players
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (isEvaluation) _evaluationBanner(context, state),
                      Text(
                        'SPIELER',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 10),
                      ...state.players.asMap().entries.map((entry) {
                        final player = entry.value;
                        final isMe =
                            player.userId == state.currentPlayer?.userId;
                        final isPlayerHost =
                            player.userId == state.lobby.hostId;

                        // Show roles in game over or if same faction mafia
                        final showRole = state.lobby.phase ==
                                AppConstants.phaseGameOver ||
                            (state.currentPlayer?.faction ==
                                    AppConstants.factionMafia &&
                                player.faction == AppConstants.factionMafia);

                        return PlayerTile(
                          name: player.displayName,
                          imageUrl: player.profileImage,
                          isAlive: player.alive,
                          isHost: isPlayerHost,
                          isCurrentUser: isMe,
                          showRole: showRole,
                          role: showRole ? player.roleDisplayName : null,
                        )
                            .animate()
                            .fadeIn(
                                delay: Duration(milliseconds: entry.key * 60))
                            .slideX(begin: 0.1);
                      }),
                    ],
                  ),
                ),

                // Host controls
                if (isHost)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: MafiaButton(
                      label: 'Voting starten',
                      isDestructive: true,
                      icon: Icons.how_to_vote,
                      onPressed: () async {
                        await ref.read(lobbyServiceProvider).startVoting(
                              lobbyId,
                              state.lobby.settings.votingDuration,
                            );
                      },
                    ).animate().fadeIn(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _factionCounter(BuildContext context, GameState state) {
    return Row(
      children: [
        _factionChip('🔪', '${state.aliveMafia.length}', AppColors.blood),
        const SizedBox(width: 8),
        _factionChip('👨‍🌾', '${state.aliveCitizens.length}', AppColors.gold),
      ],
    );
  }

  Widget _factionChip(String emoji, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _evaluationBanner(BuildContext context, GameState state) {
    final eliminated = state.players.where((p) => !p.alive).toList();

    if (eliminated.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Gleichstand — Niemand wurde eliminiert',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Cinzel',
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Find most recently dead
    final lastEliminated = eliminated.last;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blood.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.blood.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text('💀', style: TextStyle(fontSize: 40)).animate().scale(
              begin: const Offset(0.5, 0.5),
              duration: 600.ms,
              curve: Curves.elasticOut),
          const SizedBox(height: 10),
          Text(
            lastEliminated.displayName.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: AppColors.blood),
          ),
          const SizedBox(height: 4),
          Text(
            'wurde eliminiert',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${lastEliminated.roleEmoji} ${lastEliminated.roleDisplayName}',
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
