import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/game_models.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class SetupScreen extends ConsumerStatefulWidget {
  final String lobbyId;

  const SetupScreen({super.key, required this.lobbyId});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _mafiaCount = 1;
  int _citizenCount = 4;
  int _hunterCount = 0;
  int _votingDuration = 60;
  bool _loading = false;

  int get _total => _mafiaCount + _citizenCount + _hunterCount;
  bool get _isValid =>
      _total >= AppConstants.minPlayers && _total <= AppConstants.maxPlayers;

  Future<void> _saveSettings() async {
    setState(() => _loading = true);
    try {
      final settings = GameSettings(
        mafiaCount: _mafiaCount,
        citizenCount: _citizenCount,
        hunterCount: _hunterCount,
        votingDuration: _votingDuration,
      );
      await ref
          .read(lobbyServiceProvider)
          .updateSettings(widget.lobbyId, settings);

      if (mounted) context.go('/lobby/${widget.lobbyId}');
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
  void initState() {
    super.initState();
    // Load existing settings from lobby
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = ref.read(gameStateProvider(widget.lobbyId));
      gameState.whenData((state) {
        if (state == null) return;
        final s = state.lobby.settings;
        setState(() {
          _mafiaCount = s.mafiaCount;
          _citizenCount = s.citizenCount;
          _hunterCount = s.hunterCount;
          _votingDuration = s.votingDuration;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/lobby/${widget.lobbyId}'),
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.textSecondary, size: 20),
                  ),
                  Text('EINSTELLUNGEN',
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
                    const SizedBox(height: 8),

                    // ── Rollenverteilung ──────────────────────────
                    _sectionLabel('ROLLENVERTEILUNG'),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        'Gesamt: $_total Spieler',
                        style: TextStyle(
                          color: _isValid ? AppColors.gold : AppColors.blood,
                          fontSize: 13,
                          fontFamily: 'Cinzel',
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _roleCounter(
                      emoji: '🔪',
                      label: 'Mafia',
                      description: 'Kennen sich untereinander',
                      value: _mafiaCount,
                      color: AppColors.blood,
                      onDecrement: _mafiaCount > 1
                          ? () => setState(() => _mafiaCount--)
                          : null,
                      onIncrement: _total < AppConstants.maxPlayers
                          ? () => setState(() => _mafiaCount++)
                          : null,
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 12),

                    _roleCounter(
                      emoji: '👨‍🌾',
                      label: 'Bürger',
                      description: 'Keine Sonderfähigkeit',
                      value: _citizenCount,
                      color: AppColors.textSecondary,
                      onDecrement: _citizenCount > 1
                          ? () => setState(() => _citizenCount--)
                          : null,
                      onIncrement: _total < AppConstants.maxPlayers
                          ? () => setState(() => _citizenCount++)
                          : null,
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 12),

                    _roleCounter(
                      emoji: '🏹',
                      label: 'Jäger',
                      description: 'Nimmt einen Spieler mit bei Eliminierung',
                      value: _hunterCount,
                      color: AppColors.hunterLight,
                      onDecrement: _hunterCount > 0
                          ? () => setState(() => _hunterCount--)
                          : null,
                      onIncrement: _total < AppConstants.maxPlayers
                          ? () => setState(() => _hunterCount++)
                          : null,
                    ).animate().fadeIn(delay: 200.ms),

                    const OrnamentDivider(),

                    // ── Voting-Dauer ──────────────────────────────
                    _sectionLabel('VOTING-DAUER'),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      children: [60, 90, 120, 180].map((sec) {
                        final selected = _votingDuration == sec;
                        return GestureDetector(
                          onTap: () => setState(() => _votingDuration = sec),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.gold.withOpacity(0.12)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: selected
                                    ? AppColors.gold
                                    : AppColors.border,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${sec}s',
                                  style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppColors.gold
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  sec < 60 ? '${sec}s' : '${sec ~/ 60} Min',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selected
                                        ? AppColors.gold.withOpacity(0.7)
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate().fadeIn(delay: 250.ms),

                    const OrnamentDivider(),

                    // ── Validierungsfehler ────────────────────────
                    if (!_isValid)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.blood.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppColors.blood.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_outlined,
                                color: AppColors.blood, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Mindestens ${AppConstants.minPlayers} Spieler benötigt. '
                                'Aktuell: $_total',
                                style: const TextStyle(
                                    color: AppColors.blood, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().shakeX(),

                    // ── Speichern ─────────────────────────────────
                    MafiaButton(
                      label: 'Einstellungen speichern',
                      isDestructive: true,
                      isLoading: _loading,
                      onPressed: _isValid ? _saveSettings : null,
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 32),

                    // ── Info Box ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ROLLENÜBERSICHT',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: AppColors.gold),
                          ),
                          const SizedBox(height: 12),
                          _infoRow(context, '🔪', 'Mafia',
                              'Kennen sich gegenseitig. Ziel: Gleichstand erreichen.'),
                          const SizedBox(height: 8),
                          _infoRow(context, '👨‍🌾', 'Bürger',
                              'Keine Sonderfähigkeit. Ziel: Alle Mafia eliminieren.'),
                          const SizedBox(height: 8),
                          _infoRow(context, '🏹', 'Jäger',
                              'Bei Eliminierung: darf sofort einen Spieler mitnehmen.'),
                        ],
                      ),
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

  Widget _roleCounter({
    required String emoji,
    required String label,
    required String description,
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
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _counterBtn(Icons.remove, onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$value',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 22,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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

  Widget _infoRow(
      BuildContext context, String emoji, String role, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$role  ',
                  style: const TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
