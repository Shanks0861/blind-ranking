import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';
import 'phase_intro_screen.dart';

class RoleRevealScreen extends ConsumerStatefulWidget {
  final String lobbyId;
  const RoleRevealScreen({super.key, required this.lobbyId});

  @override
  ConsumerState<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends ConsumerState<RoleRevealScreen>
    with SingleTickerProviderStateMixin {
  bool _showIntro = true;
  bool _isFlipped = false;
  bool _roleRevealed = false;
  bool _confirmingStart = false;
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnim = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  void _revealRole() async {
    if (_isFlipped) return;
    _flipCtrl.forward();
    setState(() {
      _isFlipped = true;
      _roleRevealed = true;
    });

    // Mark this player as having revealed their role in Firestore
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection(AppConstants.colLobbies)
        .doc(widget.lobbyId)
        .collection(AppConstants.colPlayers)
        .doc(user.uid)
        .update({'roleRevealed': true});
  }

  Future<void> _startDiscussion() async {
    setState(() => _confirmingStart = true);
    try {
      await ref.read(lobbyServiceProvider).startDiscussion(widget.lobbyId);
    } finally {
      if (mounted) setState(() => _confirmingStart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show cinematic intro first
    if (_showIntro) {
      return PhaseIntroScreen(
        data: PhaseIntroData.roleReveal,
        onComplete: () => setState(() => _showIntro = false),
      );
    }

    final gameStateAsync = ref.watch(gameStateProvider(widget.lobbyId));

    ref.listen(gameStateProvider(widget.lobbyId), (_, next) {
      next.whenData((state) {
        if (state?.lobby.phase == AppConstants.phaseDiscussion) {
          context.go('/game/${widget.lobbyId}');
        }
      });
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.4,
                colors: [Color(0xFF120508), AppColors.background],
              ),
            ),
          ),
          gameStateAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold)),
            error: (e, _) => Center(child: Text('Fehler: $e')),
            data: (state) {
              if (state == null) return const SizedBox.shrink();
              final currentPlayer = state.currentPlayer;
              if (currentPlayer == null) {
                return const Center(child: Text('Spieler nicht gefunden'));
              }

              final isHost = currentPlayer.userId == state.lobby.hostId;

              // Check how many players have revealed their role
              final totalPlayers = state.players.length;
              final revealedCount =
                  state.players.where((p) => p.roleRevealed == true).length;
              final allRevealed = revealedCount >= totalPlayers;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      Text('DEINE ROLLE',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(letterSpacing: 4))
                          .animate()
                          .fadeIn(),

                      const SizedBox(height: 8),
                      Text(
                        currentPlayer.displayName.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(color: AppColors.gold),
                      ).animate().fadeIn(delay: 100.ms),

                      const Spacer(),

                      // Flip card
                      GestureDetector(
                        onTap: _revealRole,
                        child: AnimatedBuilder(
                          animation: _flipAnim,
                          builder: (context, child) {
                            final angle = _flipAnim.value;
                            final isShowingBack = angle > pi / 2;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(angle),
                              child: isShowingBack
                                  ? Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
                                      child: _buildRoleFront(
                                          context, currentPlayer),
                                    )
                                  : _buildCardBack(context),
                            );
                          },
                        ),
                      ),

                      const Spacer(),

                      if (!_roleRevealed)
                        Text(
                          'TIPPE UM ZU ENTHÜLLEN',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: AppColors.textMuted),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .fadeIn(duration: 800.ms)
                            .then()
                            .fadeOut(duration: 800.ms),

                      if (_roleRevealed) ...[
                        _roleDescription(context, currentPlayer.role),
                        const SizedBox(height: 20),

                        // Progress: who has revealed
                        _revealProgress(context, revealedCount, totalPlayers),
                        const SizedBox(height: 16),

                        if (isHost) ...[
                          if (!allRevealed)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: AppColors.textMuted,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Warte bis alle ihre Rolle geöffnet haben...',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn()
                          else
                            MafiaButton(
                              label: 'Diskussion starten',
                              isDestructive: true,
                              isLoading: _confirmingStart,
                              onPressed: _startDiscussion,
                            )
                                .animate()
                                .fadeIn()
                                .scale(begin: const Offset(0.9, 0.9)),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _roleRevealed
                                      ? Icons.check_circle_outline
                                      : Icons.hourglass_empty,
                                  color: _roleRevealed
                                      ? AppColors.alive
                                      : AppColors.textMuted,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _roleRevealed
                                      ? 'Rolle geöffnet — warte auf den Spielführer'
                                      : 'Warte auf den Spielführer...',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(),
                        ],
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _revealProgress(BuildContext context, int revealed, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$revealed / $total',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: revealed >= total ? AppColors.alive : AppColors.gold,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Spieler haben ihre Rolle geöffnet',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildCardBack(BuildContext context) {
    return Container(
      width: 240,
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blood.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.blood.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔪', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text('MAFIA',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: AppColors.blood.withOpacity(0.4))),
          const SizedBox(height: 8),
          Text('GEHEIME IDENTITÄT',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildRoleFront(BuildContext context, player) {
    Color roleColor;
    String roleEmoji;
    switch (player.role) {
      case AppConstants.roleMafia:
        roleColor = AppColors.blood;
        roleEmoji = '🔪';
      case AppConstants.roleHunter:
        roleColor = AppColors.hunterLight;
        roleEmoji = '🏹';
      default:
        roleColor = AppColors.gold;
        roleEmoji = '👨‍🌾';
    }
    return Container(
      width: 240,
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: roleColor.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: roleColor.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(roleEmoji, style: const TextStyle(fontSize: 70)),
          const SizedBox(height: 20),
          Text(
            player.roleDisplayName.toUpperCase(),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: roleColor,
                  letterSpacing: 3,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            player.faction == AppConstants.factionMafia
                ? 'FRAKTION: MAFIA'
                : 'FRAKTION: BÜRGER',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _roleDescription(BuildContext context, String role) {
    String desc;
    switch (role) {
      case AppConstants.roleMafia:
        desc =
            'Du bist Mafia. Täusche die Bürger, verhindere deine Entdeckung und sorge für Gleichstand.';
      case AppConstants.roleHunter:
        desc =
            'Du bist der Jäger. Wirst du eliminiert, darfst du sofort einen Spieler mit dir reißen.';
      default:
        desc =
            'Du bist Bürger. Analysiere, diskutiere und eliminiere alle Mafia-Mitglieder durch Voting.';
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        desc,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2);
  }
}
