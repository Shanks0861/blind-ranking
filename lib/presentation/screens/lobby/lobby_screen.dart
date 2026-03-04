import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class LobbyScreen extends ConsumerWidget {
  final String lobbyId;

  const LobbyScreen({super.key, required this.lobbyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStateAsync = ref.watch(gameStateProvider(lobbyId));
    final currentUserAsync = ref.watch(currentUserModelProvider);

    // Phase navigation listener
    ref.listen(gameStateProvider(lobbyId), (_, next) {
      next.whenData((state) {
        if (state == null) return;
        switch (state.lobby.phase) {
          case AppConstants.phaseRoleReveal:
            context.go('/role/$lobbyId');
          case AppConstants.phaseDiscussion:
          case AppConstants.phaseEvaluation:
            context.go('/game/$lobbyId');
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
          if (state == null) {
            return const Center(child: Text('Lobby nicht gefunden'));
          }

          final isHost = currentUserAsync.value?.uid == state.lobby.hostId;
          final players = state.players;
          final settings = state.lobby.settings;
          final totalNeeded = settings.totalPlayers;
          final isReady = players.length >= totalNeeded;

          return SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LOBBY',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: AppColors.textMuted)),
                            Text(
                              lobbyId,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    color: AppColors.gold,
                                    letterSpacing: 6,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final uid = currentUserAsync.value?.uid;
                          if (uid != null) {
                            await ref
                                .read(lobbyServiceProvider)
                                .leaveLobby(lobbyId, uid);
                          }
                          if (context.mounted) context.go(AppRoutes.home);
                        },
                        icon: const Icon(Icons.exit_to_app,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // QR Code
                        if (settings.gameMode == 'multi_device')
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: QrImageView(
                              data: lobbyId,
                              version: QrVersions.auto,
                              size: 160,
                              backgroundColor: Colors.white,
                            ),
                          )
                              .animate()
                              .fadeIn()
                              .scale(begin: const Offset(0.9, 0.9)),

                        // Players counter
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${players.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: isReady
                                          ? AppColors.alive
                                          : AppColors.gold,
                                    ),
                              ),
                              Text(
                                ' / $totalNeeded',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'SPIELER',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),

                        // Role summary
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _rolePill('🔪', '${settings.mafiaCount}',
                                  AppColors.blood),
                              _rolePill('👨‍🌾', '${settings.citizenCount}',
                                  AppColors.textSecondary),
                              if (settings.hunterCount > 0)
                                _rolePill('🏹', '${settings.hunterCount}',
                                    AppColors.hunterLight),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Player list
                        ...players.asMap().entries.map((entry) {
                          final player = entry.value;
                          final isMe =
                              player.userId == currentUserAsync.value?.uid;
                          final isPlayerHost =
                              player.userId == state.lobby.hostId;
                          return PlayerTile(
                            name: player.displayName,
                            imageUrl: player.profileImage,
                            isHost: isPlayerHost,
                            isCurrentUser: isMe,
                            trailing: isHost && !isPlayerHost
                                ? IconButton(
                                    onPressed: () async {
                                      await ref
                                          .read(lobbyServiceProvider)
                                          .removePlayer(
                                              lobbyId, player.playerId);
                                    },
                                    icon: const Icon(Icons.close,
                                        color: AppColors.textMuted, size: 16),
                                  )
                                : null,
                          )
                              .animate()
                              .fadeIn(
                                  delay: Duration(milliseconds: entry.key * 80))
                              .slideX(begin: 0.15);
                        }),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom action (host only)
                if (isHost)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: MafiaButton(
                      label: isReady
                          ? 'Rollen verteilen & Starten'
                          : 'Warte auf Spieler (${players.length}/$totalNeeded)',
                      isDestructive: true,
                      onPressed: isReady
                          ? () async {
                              await ref
                                  .read(lobbyServiceProvider)
                                  .distributeRoles(lobbyId);
                            }
                          : null,
                    ).animate().fadeIn(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _rolePill(String emoji, String count, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Text(
          count,
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
