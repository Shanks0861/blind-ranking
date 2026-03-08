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
  String? _selectedTargetId; // pending selection
  bool _hasVoted = false; // confirmed vote
  bool _casting = false;

  Future<void> _confirmVote(String voterId) async {
    if (_hasVoted || _selectedTargetId == null || _casting) return;
    setState(() => _casting = true);
    try {
      await ref.read(lobbyServiceProvider).castVote(
            lobbyId: widget.lobbyId,
            voterId: voterId,
            targetId: _selectedTargetId!,
          );
      if (mounted) setState(() => _hasVoted = true);
    } finally {
      if (mounted) setState(() => _casting = false);
    }
  }

  Future<void> _finishVoting() async {
    await ref.read(lobbyServiceProvider).evaluateVotes(widget.lobbyId);
    await ref.read(lobbyServiceProvider).checkWinCondition(widget.lobbyId);
  }

  @override
  Widget build(BuildContext context) {
    final gameStateAsync = ref.watch(gameStateProvider(widget.lobbyId));

    ref.listen(gameStateProvider(widget.lobbyId), (_, next) {
      next.whenData((state) {
        if (state == null) return;
        switch (state.lobby.phase) {
          case AppConstants.phaseSetup:
            context.go('/lobby/${widget.lobbyId}');
          case AppConstants.phaseHunterRevenge:
            context.go('/hunter/${widget.lobbyId}');
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
          // Host fix: find current player properly even if hostId matches userId
          final isHost = currentPlayer?.userId == state.lobby.hostId;
          final canVote =
              currentPlayer != null && currentPlayer.alive && !_hasVoted;
          final alivePlayers = state.alivePlayers;
          final voteCounts = state.voteCounts;
          final votedCount = state.votes.length;
          final totalAlive = alivePlayers.length;

          final countdown =
              ref.watch(votingCountdownProvider(state.lobby.votingEndsAt));

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
                    // Header
                    countdown.when(
                      loading: () => const SizedBox(height: 60),
                      error: (_, __) => const SizedBox(height: 60),
                      data: (secs) => _buildCountdownHeader(
                          context, secs, votedCount, totalAlive),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      child: Text('WÄHLE DEIN ZIEL',
                          style: Theme.of(context).textTheme.labelMedium),
                    ),

                    // Player list
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        children: [
                          // Other alive players
                          ...alivePlayers
                              .where((p) => p.userId != currentPlayer?.userId)
                              .map((player) {
                            final voteCount = voteCounts[player.playerId] ?? 0;
                            final isSelected =
                                _selectedTargetId == player.playerId;
                            final isLocked = _hasVoted && isSelected;

                            return GestureDetector(
                              onTap: canVote
                                  ? () => setState(
                                      () => _selectedTargetId = player.playerId)
                                  : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isLocked
                                      ? AppColors.blood.withOpacity(0.15)
                                      : isSelected
                                          ? AppColors.blood.withOpacity(0.08)
                                          : AppColors.card,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isLocked
                                        ? AppColors.blood
                                        : isSelected
                                            ? AppColors.blood.withOpacity(0.6)
                                            : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Selection indicator
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppColors.blood
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.blood
                                              : AppColors.border,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check,
                                              size: 14, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        player.displayName,
                                        style: TextStyle(
                                          fontFamily: 'Cinzel',
                                          fontSize: 17,
                                          color: isSelected
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    // Vote count badge
                                    if (voteCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.blood.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: AppColors.blood
                                                  .withOpacity(0.4)),
                                        ),
                                        child: Text(
                                          '$voteCount',
                                          style: const TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 13,
                                            color: AppColors.blood,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 100.ms)
                                .slideX(begin: 0.05);
                          }),

                          // Abstain — visually distinct
                          if (!_hasVoted)
                            GestureDetector(
                              onTap: canVote
                                  ? () => setState(() =>
                                      _selectedTargetId = AppConstants.abstain)
                                  : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.only(top: 6, bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedTargetId == AppConstants.abstain
                                          ? const Color(0xFF1A2A1A)
                                          : AppColors.card.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedTargetId ==
                                            AppConstants.abstain
                                        ? const Color(0xFF4CAF50)
                                        : AppColors.border.withOpacity(0.4),
                                    width: _selectedTargetId ==
                                            AppConstants.abstain
                                        ? 2
                                        : 1,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.do_not_disturb_outlined,
                                      size: 18,
                                      color: _selectedTargetId ==
                                              AppConstants.abstain
                                          ? const Color(0xFF4CAF50)
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'ENTHALTUNG',
                                      style: TextStyle(
                                        fontFamily: 'Cinzel',
                                        fontSize: 13,
                                        letterSpacing: 2,
                                        color: _selectedTargetId ==
                                                AppConstants.abstain
                                            ? const Color(0xFF4CAF50)
                                            : AppColors.textMuted,
                                        fontWeight: _selectedTargetId ==
                                                AppConstants.abstain
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 300.ms),

                          if (_hasVoted)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.how_to_vote,
                                      color: AppColors.gold, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Stimme abgegeben. Warte auf andere...',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ).animate().fadeIn(),
                            ),
                        ],
                      ),
                    ),

                    // Bottom actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        children: [
                          // Confirm vote button — only shown when something is selected and not yet voted
                          if (canVote && _selectedTargetId != null)
                            MafiaButton(
                              label: _selectedTargetId == AppConstants.abstain
                                  ? 'Enthalten ✓'
                                  : 'Jetzt voten →',
                              isDestructive:
                                  _selectedTargetId != AppConstants.abstain,
                              isLoading: _casting,
                              onPressed: () =>
                                  _confirmVote(currentPlayer!.playerId),
                            ).animate().fadeIn(duration: 200.ms),

                          if (canVote && _selectedTargetId != null)
                            const SizedBox(height: 10),

                          // Host end voting
                          if (isHost)
                            MafiaButton(
                              label: 'Voting beenden',
                              isOutlined: true,
                              onPressed: _finishVoting,
                            ).animate().fadeIn(),
                        ],
                      ),
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
                  Text('VOTING',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(letterSpacing: 3)),
                  Text('$voted / $total gestimmt',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
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
              value: (secs / 60).clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                  isUrgent ? AppColors.blood : AppColors.gold),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}
