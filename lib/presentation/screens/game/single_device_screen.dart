import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import 'phase_intro_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model for local single-device game
// ─────────────────────────────────────────────────────────────────────────────

class LocalPlayer {
  final String name;
  final String role;
  final String roleDisplay;
  final String faction;
  bool alive;
  bool hasRevealed;
  bool hasVoted;
  int votesReceived;

  LocalPlayer({
    required this.name,
    required this.role,
    required this.roleDisplay,
    required this.faction,
    this.alive = true,
    this.hasRevealed = false,
    this.hasVoted = false,
    this.votesReceived = 0,
  });
}

List<LocalPlayer> _distributeRoles(List<String> names, int mafia, int hunter) {
  final roles = <String>[];
  for (int i = 0; i < mafia; i++) roles.add(AppConstants.roleMafia);
  for (int i = 0; i < hunter; i++) roles.add(AppConstants.roleHunter);
  while (roles.length < names.length) roles.add(AppConstants.roleCitizen);
  roles.shuffle(Random.secure());

  return List.generate(names.length, (i) {
    final role = roles[i];
    return LocalPlayer(
      name: names[i],
      role: role,
      roleDisplay: role == AppConstants.roleMafia
          ? 'Mafia'
          : role == AppConstants.roleHunter
              ? 'Jäger'
              : 'Bürger',
      faction: role == AppConstants.roleMafia
          ? AppConstants.factionMafia
          : AppConstants.factionCitizen,
    );
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Single Device Screen
// ─────────────────────────────────────────────────────────────────────────────

enum _SDPhase {
  setup,
  roleRevealIntro,
  roleReveal,
  discussionIntro,
  discussion,
  votingIntro,
  voting,
  result
}

class SingleDeviceScreen extends StatefulWidget {
  const SingleDeviceScreen({super.key});

  @override
  State<SingleDeviceScreen> createState() => _SingleDeviceScreenState();
}

class _SingleDeviceScreenState extends State<SingleDeviceScreen> {
  _SDPhase _phase = _SDPhase.setup;

  // Setup
  final List<TextEditingController> _nameControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _mafiaCount = 1;
  int _hunterCount = 0;

  // Game state
  List<LocalPlayer> _players = [];
  int _currentRevealIndex = 0;
  String? _eliminatedName;
  String? _winner;

  int get _totalPlayers =>
      _nameControllers.where((c) => c.text.trim().isNotEmpty).length;
  bool get _isValid => _totalPlayers >= 4;

  void _startGame() {
    final names = _nameControllers
        .map((c) => c.text.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.length < 4) return;
    setState(() {
      _players = _distributeRoles(names, _mafiaCount, _hunterCount);
      _currentRevealIndex = 0;
      _phase = _SDPhase.roleRevealIntro;
    });
  }

  void _addPlayer() {
    if (_nameControllers.length >= AppConstants.maxPlayers) return;
    setState(() => _nameControllers.add(TextEditingController()));
  }

  void _removePlayer(int index) {
    if (_nameControllers.length <= 3) return;
    setState(() {
      _nameControllers[index].dispose();
      _nameControllers.removeAt(index);
    });
  }

  void _nextReveal() {
    if (_currentRevealIndex < _players.length - 1) {
      setState(() {
        _players[_currentRevealIndex].hasRevealed = true;
        _currentRevealIndex++;
      });
    } else {
      setState(() {
        _players[_currentRevealIndex].hasRevealed = true;
        _phase = _SDPhase.discussionIntro;
      });
    }
  }

  void _startVoting() {
    setState(() {
      for (final p in _players) {
        p.votesReceived = 0;
        p.hasVoted = false;
      }
      _phase = _SDPhase.votingIntro;
    });
  }

  void _castVote(String targetName) {
    final alivePlayers = _players.where((p) => p.alive).toList();
    final aliveCount = alivePlayers.length;
    final votedCount = alivePlayers.where((p) => p.hasVoted).length;

    // Mark current voter as voted and add vote to target
    // Find first alive player who hasn't voted
    final voter = alivePlayers.firstWhere((p) => !p.hasVoted,
        orElse: () => alivePlayers.first);
    voter.hasVoted = true;
    _players.firstWhere((p) => p.name == targetName).votesReceived++;

    setState(() {});

    // All voted
    if (votedCount + 1 >= aliveCount) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _eliminateVoted();
      });
    }
  }

  void _eliminateVoted() {
    // Find player with most votes
    final alive = _players.where((p) => p.alive).toList();
    alive.sort((a, b) => b.votesReceived.compareTo(a.votesReceived));
    final eliminated = alive.first;
    eliminated.alive = false;
    _eliminatedName = eliminated.name;

    // Check win condition
    final alivePlayers = _players.where((p) => p.alive).toList();
    final aliveMafia = alivePlayers
        .where((p) => p.faction == AppConstants.factionMafia)
        .length;
    final aliveCitizen = alivePlayers
        .where((p) => p.faction == AppConstants.factionCitizen)
        .length;

    String? winner;
    if (aliveMafia == 0) winner = 'citizen';
    if (aliveMafia >= aliveCitizen) winner = 'mafia';

    setState(() {
      _winner = winner;
      _phase = _SDPhase.result;
    });
  }

  void _continueAfterResult() {
    if (_winner != null) return; // game over
    // Continue to next round discussion
    setState(() {
      _eliminatedName = null;
      _phase = _SDPhase.discussionIntro;
    });
  }

  @override
  void dispose() {
    for (final c in _nameControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _SDPhase.setup => _buildSetup(),
      _SDPhase.roleRevealIntro => PhaseIntroScreen(
          data: PhaseIntroData.roleReveal,
          onComplete: () => setState(() => _phase = _SDPhase.roleReveal),
        ),
      _SDPhase.roleReveal => _buildRoleReveal(),
      _SDPhase.discussionIntro => PhaseIntroScreen(
          data: PhaseIntroData.discussion,
          onComplete: () => setState(() => _phase = _SDPhase.discussion),
        ),
      _SDPhase.discussion => _buildDiscussion(),
      _SDPhase.votingIntro => PhaseIntroScreen(
          data: PhaseIntroData.voting,
          onComplete: () => setState(() => _phase = _SDPhase.voting),
        ),
      _SDPhase.voting => _buildVoting(),
      _SDPhase.result => _buildResult(),
    };
  }

  // ─── SETUP ───────────────────────────────────────────────────────────────

  Widget _buildSetup() {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.4,
                colors: [Color(0xFF120508), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go(AppRoutes.home),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppColors.textSecondary, size: 20),
                      ),
                      Text('EIN GERÄT',
                          style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Player names
                        Text('SPIELER',
                            style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 12),
                        ...List.generate(
                            _nameControllers.length,
                            (i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _nameControllers[i],
                                          style: const TextStyle(
                                              color: AppColors.textPrimary),
                                          decoration: InputDecoration(
                                            labelText: 'Spieler ${i + 1}',
                                            prefixIcon: const Icon(
                                                Icons.person_outline,
                                                color: AppColors.textMuted,
                                                size: 18),
                                          ),
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                      if (_nameControllers.length > 3) ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () => _removePlayer(i),
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: AppColors.blood,
                                              size: 20),
                                        ),
                                      ],
                                    ],
                                  ),
                                )),

                        if (_nameControllers.length < AppConstants.maxPlayers)
                          TextButton.icon(
                            onPressed: _addPlayer,
                            icon: const Icon(Icons.add,
                                color: AppColors.gold, size: 18),
                            label: const Text('Spieler hinzufügen',
                                style: TextStyle(color: AppColors.gold)),
                          ),

                        const OrnamentDivider(),

                        // Role counts
                        Text('ROLLEN',
                            style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 16),
                        _countRow(
                          '🔪 Mafia',
                          _mafiaCount,
                          onMinus: _mafiaCount > 1
                              ? () => setState(() => _mafiaCount--)
                              : null,
                          onPlus: () => setState(() => _mafiaCount++),
                        ),
                        const SizedBox(height: 10),
                        _countRow(
                          '🏹 Jäger',
                          _hunterCount,
                          onMinus: _hunterCount > 0
                              ? () => setState(() => _hunterCount--)
                              : null,
                          onPlus: () => setState(() => _hunterCount++),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bürger: ${(_totalPlayers - _mafiaCount - _hunterCount).clamp(0, 99)}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
                        ),

                        const SizedBox(height: 32),

                        if (!_isValid)
                          Center(
                            child: Text(
                              'Mindestens 4 Spieler nötig',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13),
                            ),
                          ),

                        const SizedBox(height: 12),

                        MafiaButton(
                          label: 'Spiel starten',
                          isDestructive: true,
                          onPressed: _isValid ? _startGame : null,
                        ),
                        const SizedBox(height: 32),
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

  Widget _countRow(String label, int count,
      {VoidCallback? onMinus, VoidCallback? onPlus}) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 15))),
        IconButton(
          onPressed: onMinus,
          icon: Icon(Icons.remove_circle_outline,
              color: onMinus != null ? AppColors.blood : AppColors.textMuted),
        ),
        SizedBox(
          width: 32,
          child: Text('$count',
              style: const TextStyle(
                  color: AppColors.gold, fontSize: 20, fontFamily: 'Cinzel'),
              textAlign: TextAlign.center),
        ),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle_outline, color: AppColors.alive),
        ),
      ],
    );
  }

  // ─── ROLE REVEAL ─────────────────────────────────────────────────────────

  Widget _buildRoleReveal() {
    final player = _players[_currentRevealIndex];
    final allRevealed = _players.every((p) => p.hasRevealed) &&
        _currentRevealIndex == _players.length - 1;

    return _PassDeviceWrapper(
      playerName: player.name,
      instruction: 'Schau dir deine Rolle an und halte sie geheim!',
      child: _RoleCardReveal(
        player: player,
        isLast: _currentRevealIndex == _players.length - 1,
        onNext: _nextReveal,
      ),
    );
  }

  // ─── DISCUSSION ──────────────────────────────────────────────────────────

  Widget _buildDiscussion() {
    final alive = _players.where((p) => p.alive).toList();
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.4,
                colors: [Color(0xFF0A0808), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('DISKUSSION',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: AppColors.blood))
                      .animate()
                      .fadeIn(),
                  const SizedBox(height: 8),
                  Text('${alive.length} Spieler am Leben',
                      style: Theme.of(context).textTheme.bodySmall),
                  const OrnamentDivider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: alive.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline,
                                color: AppColors.textMuted, size: 18),
                            const SizedBox(width: 12),
                            Text(alive[i].name,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16)),
                          ],
                        ),
                      ).animate().fadeIn(delay: (i * 80).ms),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Diskutiert und findet die Mafia.\nWenn ihr bereit seid, startet das Voting.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  MafiaButton(
                    label: 'Voting starten',
                    isDestructive: true,
                    onPressed: _startVoting,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── VOTING ──────────────────────────────────────────────────────────────

  Widget _buildVoting() {
    final alivePlayers = _players.where((p) => p.alive).toList();
    final votersLeft = alivePlayers.where((p) => !p.hasVoted).toList();
    final currentVoter = votersLeft.isNotEmpty ? votersLeft.first : null;

    if (currentVoter == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return _PassDeviceWrapper(
      playerName: currentVoter.name,
      instruction: 'Wähle wen du eliminieren möchtest',
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            '${votersLeft.length} von ${alivePlayers.length} haben noch nicht gewählt',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: alivePlayers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final target = alivePlayers[i];
                final isSelf = target.name == currentVoter.name;
                return GestureDetector(
                  onTap: isSelf ? null : () => _castVote(target.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelf
                          ? AppColors.card.withOpacity(0.4)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelf
                            ? AppColors.border.withOpacity(0.3)
                            : AppColors.blood.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isSelf ? '🚫' : '🗡️',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          target.name,
                          style: TextStyle(
                            color: isSelf
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            fontSize: 18,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                        if (isSelf) ...[
                          const Spacer(),
                          Text('Du selbst',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.1);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── RESULT ──────────────────────────────────────────────────────────────

  Widget _buildResult() {
    final isGameOver = _winner != null;
    final isMafiaWin = _winner == 'mafia';

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  isGameOver
                      ? (isMafiaWin
                          ? const Color(0xFF1A0508)
                          : const Color(0xFF081A0A))
                      : const Color(0xFF0A0808),
                  AppColors.background,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isGameOver ? (isMafiaWin ? '💀' : '⚖️') : '🗡️',
                      style: const TextStyle(fontSize: 72),
                    ).animate().fadeIn().scale(begin: const Offset(0.3, 0.3)),
                    const SizedBox(height: 24),
                    Text(
                      isGameOver
                          ? (isMafiaWin ? 'MAFIA GEWINNT' : 'BÜRGER GEWINNEN')
                          : 'ELIMINIERT',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isGameOver
                            ? (isMafiaWin ? AppColors.blood : AppColors.alive)
                            : AppColors.blood,
                        letterSpacing: 3,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 16),
                    if (_eliminatedName != null) ...[
                      Text(
                        _eliminatedName!,
                        style: const TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 28,
                          color: AppColors.textPrimary,
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 8),
                      Text(
                        'wurde eliminiert — ${_players.firstWhere((p) => p.name == _eliminatedName).roleDisplay}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ).animate().fadeIn(delay: 800.ms),
                    ],
                    const SizedBox(height: 40),
                    if (isGameOver) ...[
                      // Show all roles
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Text('ALLE ROLLEN',
                                style: Theme.of(context).textTheme.labelMedium),
                            const SizedBox(height: 12),
                            ..._players.map((p) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        p.faction == AppConstants.factionMafia
                                            ? '🔪'
                                            : '👨‍🌾',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(p.name,
                                          style: TextStyle(
                                            color: p.alive
                                                ? AppColors.textPrimary
                                                : AppColors.textMuted,
                                            decoration: p.alive
                                                ? null
                                                : TextDecoration.lineThrough,
                                          )),
                                      const Spacer(),
                                      Text(p.roleDisplay,
                                          style: TextStyle(
                                            color: p.faction ==
                                                    AppConstants.factionMafia
                                                ? AppColors.blood
                                                : AppColors.gold,
                                            fontSize: 12,
                                          )),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ).animate().fadeIn(delay: 1000.ms),

                      const SizedBox(height: 24),

                      MafiaButton(
                        label: 'Nochmal spielen',
                        isDestructive: false,
                        onPressed: () => setState(() {
                          _phase = _SDPhase.setup;
                          for (final c in _nameControllers) c.clear();
                        }),
                      ),
                    ] else ...[
                      Text(
                        'Das Spiel geht weiter...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      MafiaButton(
                        label: 'Diskussion fortsetzen',
                        isDestructive: true,
                        onPressed: _continueAfterResult,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pass Device Wrapper — zeigt wer dran ist
// ─────────────────────────────────────────────────────────────────────────────

class _PassDeviceWrapper extends StatefulWidget {
  final String playerName;
  final String instruction;
  final Widget child;

  const _PassDeviceWrapper({
    required this.playerName,
    required this.instruction,
    required this.child,
  });

  @override
  State<_PassDeviceWrapper> createState() => _PassDeviceWrapperState();
}

class _PassDeviceWrapperState extends State<_PassDeviceWrapper> {
  bool _devicePassed = false;

  @override
  void didUpdateWidget(_PassDeviceWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerName != widget.playerName) {
      setState(() => _devicePassed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_devicePassed) {
      return Scaffold(
        body: GestureDetector(
          onTap: () => setState(() => _devicePassed = true),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.4,
                    colors: [Color(0xFF0D0D0D), AppColors.background],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📱', style: TextStyle(fontSize: 64))
                          .animate()
                          .fadeIn()
                          .scale(begin: const Offset(0.5, 0.5)),
                      const SizedBox(height: 32),
                      Text(
                        'GERÄT WEITERGEBEN',
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 11,
                          letterSpacing: 5,
                          color: AppColors.textMuted,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 16),
                      Text(
                        widget.playerName,
                        style: const TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 500.ms),
                      const SizedBox(height: 12),
                      Text(
                        widget.instruction,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 700.ms),
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
                          .fadeIn(delay: 1200.ms, duration: 700.ms)
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    widget.playerName.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                      letterSpacing: 3,
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 4),
                  Text(widget.instruction,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role Card Flip Widget
// ─────────────────────────────────────────────────────────────────────────────

class _RoleCardReveal extends StatefulWidget {
  final LocalPlayer player;
  final bool isLast;
  final VoidCallback onNext;

  const _RoleCardReveal({
    required this.player,
    required this.isLast,
    required this.onNext,
  });

  @override
  State<_RoleCardReveal> createState() => _RoleCardRevealState();
}

class _RoleCardRevealState extends State<_RoleCardReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 600.ms);
    _anim = Tween<double>(begin: 0, end: pi)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (_flipped) return;
    _ctrl.forward();
    setState(() => _flipped = true);
  }

  @override
  Widget build(BuildContext context) {
    Color roleColor;
    String roleEmoji;
    switch (widget.player.role) {
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _flip,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) {
              final angle = _anim.value;
              final showFront = angle > pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: showFront
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: _buildFront(roleColor, roleEmoji),
                      )
                    : _buildBack(),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        if (!_flipped)
          Text(
            'TIPPE UM ZU ENTHÜLLEN',
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 11, letterSpacing: 3),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 700.ms)
              .then()
              .fadeOut(duration: 700.ms),
        if (_flipped) ...[
          // Role description
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              widget.player.role == AppConstants.roleMafia
                  ? 'Du bist Mafia. Täusche die Bürger und verhindere deine Entdeckung.'
                  : widget.player.role == AppConstants.roleHunter
                      ? 'Du bist Jäger. Wirst du eliminiert, reißt du einen Spieler mit.'
                      : 'Du bist Bürger. Finde und eliminiere alle Mafia-Mitglieder.',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          MafiaButton(
            label: widget.isLast
                ? 'Alle Rollen verteilt ✓'
                : 'Handy weitergeben →',
            isDestructive: !widget.isLast,
            onPressed: widget.onNext,
          ).animate().fadeIn(),
        ],
      ],
    );
  }

  Widget _buildBack() {
    return Container(
      width: 220,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blood.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(color: AppColors.blood.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔪', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('MAFIA',
              style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 20,
                  color: AppColors.blood.withOpacity(0.3))),
          const SizedBox(height: 6),
          Text('GEHEIME IDENTITÄT',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 10, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildFront(Color color, String emoji) {
    return Container(
      width: 220,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(widget.player.roleDisplay.toUpperCase(),
              style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 22,
                  color: color,
                  letterSpacing: 3)),
          const SizedBox(height: 6),
          Text(
            widget.player.faction == AppConstants.factionMafia
                ? 'FRAKTION: MAFIA'
                : 'FRAKTION: BÜRGER',
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 10, letterSpacing: 2),
          ),
        ],
      ),
    );
  }
}
