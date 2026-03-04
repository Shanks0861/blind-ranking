import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class VotingScreen extends ConsumerStatefulWidget {
  final String lobbyId;

  const VotingScreen({super.key, required this.lobbyId});

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  String? _selectedTargetId;
  bool _hasVoted = false;

  // Phase listener
  @override
  void initState() {
    super.initState();
  }

  Future<void> _castVote(String voterId, String targetId) async {
    if (_hasVoted) return;
    setState(() {
      _selectedTargetId = targetId;
      _hasVoted = true;
    });
    await ref.read(lobbyServiceProvider).castVote(
          lobbyId: widget.lobbyId,
          voterId: voterId,
          targetId: targetId,
        );
  }

  Future<void> _finishVoting() async {
    await ref.read(lobbyServiceProvider).evaluateVotes(widget.lobbyId);
    await ref.read(lobbyServiceProvider).checkWinCondition(widget.lobbyId);
  }

  @override
  Widget build(BuildContext context) {
    final gameStateAsync = ref.watch(gameStateProvider(widget.lobbyId));

    // Phase navigation
    ref.listen(gameStateProvider(widget.lobbyId), (_, next) {
      next.whenData((state) {
        if (state == null) return;
        switch (state.lobby.phase) {
          case AppConstants.phaseEvaluation:
          case AppConstants.phaseDiscussion:
            context.go('/game/${widget.lobbyId}');
          case AppConstants.phaseGameOver:
            context.go('/gameover/${widget.lobbyId}');
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

          final currentPlayer = state.currentPlayer;
          final isHost = currentPlayer?.userId == state.lobby.hostId;
          final alivePlayers = state.alivePlayers;
          final voteCounts = state.voteCounts;
          final votedCount = state.votes.length;
          final totalAlive = alivePlayers.length;

          final countdown =
              ref.watch(votingCountdownProvider(state.lobby.votingEndsAt));

          // Auto-end if time's up and host
          countdown.whenData((secs) {
            if (secs <= 0 && isHost) {
              Future.microtask(_finishVoting);
            }
          });

          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [Color(0xFF1A0808), AppColors.background],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Countdown header
                    countdown.when(
                      loading: () => const SizedBox(height: 60),
                      error: (_, __) => const SizedBox(height: 60),
                      data: (secs) => _buildCountdownHeader(
                          context, secs, votedCount, totalAlive),
                    ),

                    // Vote progress list
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Text(
                        'LIVE-STIMMEN',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          ...alivePlayers
                              .where((p) => p.userId != currentPlayer?.userId)
                              .map((player) {
                            final voteCount = voteCounts[player.playerId] ?? 0;
                            final isSelected =
                                _selectedTargetId == player.playerId;

                            return GestureDetector(
                              onTap: !_hasVoted &&
                                      currentPlayer != null &&
                                      currentPlayer.alive
                                  ? () => _castVote(
                                      currentPlayer.playerId, player.playerId)
                                  : null,
                              child: VoteProgressBar(
                                playerName: player.displayName,
                                votes: voteCount,
                                total: totalAlive,
                                isSelected: isSelected,
                              ),
                            );
                          }),

                          // Abstain option
                          if (!_hasVoted && currentPlayer?.alive == true)
                            GestureDetector(
                              onTap: () => _castVote(currentPlayer!.playerId,
                                  AppConstants.abstain),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedTargetId == AppConstants.abstain
                                          ? AppColors.border.withOpacity(0.3)
                                          : AppColors.card,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppColors.border,
                                      style: BorderStyle.solid),
                                ),
                                child: const Center(
                                  child: Text(
                                    'ENTHALTUNG',
                                    style: TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          if (_hasVoted)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Du hast gewählt. Warte auf andere Spieler...',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ).animate().fadeIn(),
                            ),
                        ],
                      ),
                    ),

                    // Host: end voting early
                    if (isHost)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        child: MafiaButton(
                          label: 'Voting beenden',
                          isDestructive: true,
                          onPressed: _finishVoting,
                        ).animate().fadeIn(),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCountdownHeader(
      BuildContext context, int secs, int voted, int total) {
    final fraction = total > 0 ? secs / 60 : 0.0;
    final isUrgent = secs <= 10;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VOTING',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(letterSpacing: 3),
                  ),
                  Text(
                    '$voted / $total gestimmt',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              // Countdown circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUrgent
                      ? AppColors.blood.withOpacity(0.15)
                      : AppColors.card,
                  border: Border.all(
                    color: isUrgent ? AppColors.blood : AppColors.gold,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$secs',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isUrgent ? AppColors.blood : AppColors.gold,
                    ),
                  ),
                ),
              ).animate(target: isUrgent ? 1 : 0).shake(hz: isUrgent ? 3 : 0),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUrgent ? AppColors.blood : AppColors.gold,
              ),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}
