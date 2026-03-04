import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// Cinematic phase intro — shown before each game phase
class PhaseIntroScreen extends StatefulWidget {
  final PhaseIntroData data;
  final VoidCallback onComplete;

  const PhaseIntroScreen({
    super.key,
    required this.data,
    required this.onComplete,
  });

  @override
  State<PhaseIntroScreen> createState() => _PhaseIntroScreenState();
}

class _PhaseIntroScreenState extends State<PhaseIntroScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-advance after duration
    Future.delayed(widget.data.duration, () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onComplete,
      child: Scaffold(
        body: Stack(
          children: [
            // Dark atmospheric background
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.5,
                  colors: [
                    widget.data.glowColor.withOpacity(0.15),
                    AppColors.background,
                  ],
                ),
              ),
            ),

            // Vignette overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),

            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Text(
                      widget.data.emoji,
                      style: const TextStyle(fontSize: 64),
                    ).animate().fadeIn(duration: 600.ms).scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 600.ms,
                        curve: Curves.easeOut),

                    const SizedBox(height: 32),

                    // Phase label
                    Text(
                      widget.data.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.data.glowColor.withOpacity(0.7),
                        letterSpacing: 6,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      widget.data.title,
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: widget.data.glowColor,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: widget.data.glowColor.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 600.ms)
                        .slideY(begin: 0.2, delay: 500.ms),

                    const SizedBox(height: 24),

                    // Ornament
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 40,
                            height: 1,
                            color: widget.data.glowColor.withOpacity(0.3)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('✦',
                              style: TextStyle(
                                  color: widget.data.glowColor.withOpacity(0.5),
                                  fontSize: 10)),
                        ),
                        Container(
                            width: 40,
                            height: 1,
                            color: widget.data.glowColor.withOpacity(0.3)),
                      ],
                    ).animate().fadeIn(delay: 700.ms),

                    const SizedBox(height: 24),

                    // Description
                    Text(
                      widget.data.description,
                      style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.8,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 700.ms)
                        .slideY(begin: 0.1, delay: 800.ms),

                    const SizedBox(height: 48),

                    // Tap to continue hint
                    Text(
                      'Tippe um fortzufahren',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted.withOpacity(0.5),
                        letterSpacing: 2,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .fadeIn(delay: 1500.ms, duration: 800.ms)
                        .then()
                        .fadeOut(duration: 800.ms),
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

class PhaseIntroData {
  final String emoji;
  final String label;
  final String title;
  final String description;
  final Color glowColor;
  final Duration duration;

  const PhaseIntroData({
    required this.emoji,
    required this.label,
    required this.title,
    required this.description,
    required this.glowColor,
    this.duration = const Duration(seconds: 6),
  });

  // ── Predefined phase intros ──────────────────────────────────────────────

  static const roleReveal = PhaseIntroData(
    emoji: '🔮',
    label: 'Rollenvergabe',
    title: 'Die Schicksalskarten werden verteilt',
    description:
        'Jeder Spieler erhält seine geheime Rolle.\nÖffne sie — aber verrate sie niemandem.\nDein Leben hängt davon ab.',
    glowColor: AppColors.gold,
    duration: Duration(seconds: 6),
  );

  static const discussion = PhaseIntroData(
    emoji: '👁️',
    label: 'Diskussion',
    title: 'Die Lügen beginnen',
    description:
        'Jeder kennt seine Rolle — doch die Verräter verstecken sich.\nDiskutiert. Beobachtet. Misstraut.\nDie Wahrheit liegt im Verborgenen.',
    glowColor: AppColors.blood,
    duration: Duration(seconds: 6),
  );

  static const voting = PhaseIntroData(
    emoji: '⚖️',
    label: 'Abstimmung',
    title: 'Das Urteil wird gesprochen',
    description:
        'Die Zeit der Worte ist vorbei.\nNun entscheidet die Gemeinschaft.\nEiner wird fallen — trefft die richtige Wahl.',
    glowColor: Color(0xFFB8860B),
    duration: Duration(seconds: 5),
  );

  static const night = PhaseIntroData(
    emoji: '🌙',
    label: 'Nacht',
    title: 'Die Dunkelheit erwacht',
    description:
        'Die Stadt schläft — doch die Mafia nicht.\nIm Schatten der Nacht wird ein Opfer auserwählt.\nMorgen früh wird man ihn vermissen.',
    glowColor: Color(0xFF4A0080),
    duration: Duration(seconds: 6),
  );

  static const evaluation = PhaseIntroData(
    emoji: '🩸',
    label: 'Auswertung',
    title: 'Das Ergebnis wird enthüllt',
    description:
        'Die Stimmen sind gezählt.\nDas Schicksal ist besiegelt.\nWer hat die Gemeinschaft verraten?',
    glowColor: AppColors.blood,
    duration: Duration(seconds: 5),
  );

  static const guestJoin = PhaseIntroData(
    emoji: '🚪',
    label: 'Gastzugang',
    title: 'Ein Fremder betritt den Raum',
    description:
        'Kein Konto — kein Name — kein Vertrauen.\nNur ein Lobby-Code trennt dich vom Spiel.\nBist du bereit?',
    glowColor: AppColors.textSecondary,
    duration: Duration(seconds: 5),
  );
}
