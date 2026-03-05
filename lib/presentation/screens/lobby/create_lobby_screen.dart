import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/game_models.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class CreateLobbyScreen extends ConsumerStatefulWidget {
  const CreateLobbyScreen({super.key});

  @override
  ConsumerState<CreateLobbyScreen> createState() => _CreateLobbyScreenState();
}

class _CreateLobbyScreenState extends ConsumerState<CreateLobbyScreen> {
  int _mafiaCount = 1;
  int _citizenCount = 4;
  int _hunterCount = 0;
  int _votingDuration = 60;
  String _gameMode = 'multi_device';
  bool _loading = false;

  int get _total => _mafiaCount + _citizenCount + _hunterCount;
  bool get _isValid =>
      _total >= AppConstants.minPlayers &&
      _total <= AppConstants.maxPlayers &&
      _mafiaCount >= 1;

  Future<void> _createLobby() async {
    // Single device — go directly to local game
    if (_gameMode == 'single_device') {
      context.go(AppRoutes.singleDevice);
      return;
    }

    setState(() => _loading = true);
    try {
      final user = await ref.read(authServiceProvider).getCurrentUserModel();
      if (user == null) return;

      final settings = GameSettings(
        mafiaCount: _mafiaCount,
        citizenCount: _citizenCount,
        hunterCount: _hunterCount,
        votingDuration: _votingDuration,
        gameMode: _gameMode,
      );

      final lobby = await ref.read(lobbyServiceProvider).createLobby(
            hostId: user.uid,
            settings: settings,
          );

      // Join as first player
      await ref.read(lobbyServiceProvider).joinLobby(
            lobbyId: lobby.lobbyId,
            user: user,
          );

      if (mounted) {
        context.go('/lobby/${lobby.lobbyId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                  Text('LOBBY ERSTELLEN',
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
                    // Game mode selector
                    _sectionLabel('SPIELMODUS'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _modeCard(
                            title: 'Ein-Gerät',
                            subtitle: 'Gerät weitergeben',
                            icon: Icons.smartphone,
                            selected: _gameMode == 'single_device',
                            onTap: () =>
                                setState(() => _gameMode = 'single_device'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _modeCard(
                            title: 'Multi-Gerät',
                            subtitle: 'QR-Code Lobby',
                            icon: Icons.devices,
                            selected: _gameMode == 'multi_device',
                            onTap: () =>
                                setState(() => _gameMode = 'multi_device'),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms),

                    if (_gameMode == 'multi_device') ...[
                      const SizedBox(height: 32),

                      // Role distribution
                      _sectionLabel('ROLLENVERTEILUNG'),
                      const SizedBox(height: 4),
                      Text(
                        'Gesamt: $_total Spieler',
                        style: TextStyle(
                          color: _isValid ? AppColors.gold : AppColors.blood,
                          fontSize: 13,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                      const SizedBox(height: 16),

                      _roleCounter(
                        emoji: '🔪',
                        label: 'Mafia',
                        value: _mafiaCount,
                        color: AppColors.blood,
                        onDecrement: _mafiaCount > 1
                            ? () => setState(() => _mafiaCount--)
                            : null,
                        onIncrement: _total < AppConstants.maxPlayers
                            ? () => setState(() => _mafiaCount++)
                            : null,
                      ).animate().fadeIn(delay: 150.ms),

                      const SizedBox(height: 12),

                      _roleCounter(
                        emoji: '👨‍🌾',
                        label: 'Bürger',
                        value: _citizenCount,
                        color: AppColors.textSecondary,
                        onDecrement: _citizenCount > 1
                            ? () => setState(() => _citizenCount--)
                            : null,
                        onIncrement: _total < AppConstants.maxPlayers
                            ? () => setState(() => _citizenCount++)
                            : null,
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 12),

                      _roleCounter(
                        emoji: '🏹',
                        label: 'Jäger',
                        value: _hunterCount,
                        color: AppColors.hunterLight,
                        onDecrement: _hunterCount > 0
                            ? () => setState(() => _hunterCount--)
                            : null,
                        onIncrement: _total < AppConstants.maxPlayers
                            ? () => setState(() => _hunterCount++)
                            : null,
                      ).animate().fadeIn(delay: 250.ms),

                      const SizedBox(height: 32),

                      // Voting duration
                      _sectionLabel('VOTING-DAUER'),
                      const SizedBox(height: 12),
                      Row(
                        children: [60, 90, 120, 180].map((sec) {
                          final selected = _votingDuration == sec;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _votingDuration = sec),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.gold.withOpacity(0.15)
                                      : AppColors.card,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.gold
                                        : AppColors.border,
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  '${sec}s',
                                  style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? AppColors.gold
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 40),
                    ], // end multi_device only

                    const SizedBox(height: 32),

                    if (!_isValid && _gameMode == 'multi_device')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.blood.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: AppColors.blood.withOpacity(0.4)),
                          ),
                          child: Text(
                            'Mindestens ${AppConstants.minPlayers} Spieler benötigt.',
                            style: const TextStyle(
                                color: AppColors.blood, fontSize: 13),
                          ),
                        ),
                      ),

                    MafiaButton(
                      label: _gameMode == 'single_device'
                          ? 'Spiel starten'
                          : 'Lobby erstellen',
                      isDestructive: true,
                      isLoading: _loading,
                      onPressed: (_gameMode == 'single_device' || _isValid)
                          ? _createLobby
                          : null,
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Cinzel',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }

  Widget _modeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.blood.withOpacity(0.1) : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.blood : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? AppColors.blood : AppColors.textSecondary,
                size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.blood : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _roleCounter({
    required String emoji,
    required String label,
    required int value,
    required Color color,
    required VoidCallback? onDecrement,
    required VoidCallback? onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _counterBtn(Icons.remove, onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              '$value',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          _counterBtn(Icons.add, onIncrement),
        ],
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color:
              onTap != null ? AppColors.surfaceElevated : AppColors.background,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: onTap != null ? AppColors.border : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}
