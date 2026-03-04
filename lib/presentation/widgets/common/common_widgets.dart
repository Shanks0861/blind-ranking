import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mafia_game/core/theme/app_theme.dart';

// ─────────────────────────────────────────────
// MAFIA BUTTON — primary dramatic CTA
// ─────────────────────────────────────────────
class MafiaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;
  final bool isOutlined;
  final IconData? icon;

  const MafiaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.blood : AppColors.gold;

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: _buildChild(color),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive ? AppColors.blood : AppColors.gold,
        foregroundColor: isDestructive ? Colors.white : AppColors.background,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 0,
      ),
      child: _buildChild(isDestructive ? Colors.white : AppColors.background),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              )),
        ],
      );
    }
    return Text(label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ));
  }
}

// ─────────────────────────────────────────────
// PLAYER AVATAR TILE
// ─────────────────────────────────────────────
class PlayerTile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isAlive;
  final bool isHost;
  final bool isCurrentUser;
  final String? role;
  final bool showRole;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PlayerTile({
    super.key,
    required this.name,
    this.imageUrl,
    this.isAlive = true,
    this.isHost = false,
    this.isCurrentUser = false,
    this.role,
    this.showRole = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isCurrentUser ? AppColors.card.withOpacity(0.8) : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentUser
                ? AppColors.gold.withOpacity(0.4)
                : isAlive
                    ? AppColors.border
                    : AppColors.dead.withOpacity(0.5),
            width: isCurrentUser ? 1 : 1,
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isAlive
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          decoration:
                              isAlive ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      if (isHost) ...[
                        const SizedBox(width: 6),
                        _badge('HOST', AppColors.gold),
                      ],
                      if (isCurrentUser) ...[
                        const SizedBox(width: 6),
                        _badge('ICH', AppColors.blood),
                      ],
                    ],
                  ),
                  if (showRole && role != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        role!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!isAlive)
              const Icon(Icons.close, color: AppColors.dead, size: 18),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceElevated,
            border: Border.all(
              color:
                  isAlive ? AppColors.border : AppColors.dead.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: imageUrl != null
              ? ClipOval(
                  child: Image.network(imageUrl!, fit: BoxFit.cover),
                )
              : Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color:
                          isAlive ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                ),
        ),
        if (!isAlive)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PHASE HEADER
// ─────────────────────────────────────────────
class PhaseHeader extends StatelessWidget {
  final String phase;
  final String subtitle;
  final IconData? icon;

  const PhaseHeader({
    super.key,
    required this.phase,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null)
          Icon(icon, color: AppColors.gold, size: 32)
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.5, 0.5)),
        const SizedBox(height: 12),
        Text(
          phase.toUpperCase(),
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ORNAMENTAL DIVIDER
// ─────────────────────────────────────────────
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.border,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '✦',
              style: TextStyle(
                  color: AppColors.gold.withOpacity(0.5), fontSize: 12),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.border,
                    Colors.transparent,
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

// ─────────────────────────────────────────────
// VOTE PROGRESS BAR
// ─────────────────────────────────────────────
class VoteProgressBar extends StatelessWidget {
  final int votes;
  final int total;
  final String playerName;
  final bool isSelected;

  const VoteProgressBar({
    super.key,
    required this.votes,
    required this.total,
    required this.playerName,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? votes / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.blood.withOpacity(0.1) : AppColors.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color:
              isSelected ? AppColors.blood.withOpacity(0.5) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(playerName,
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
              Text(
                '$votes',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: votes > 0 ? AppColors.blood : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                votes > 0 ? AppColors.blood : AppColors.border,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }
}

// ─────────────────────────────────────────────
// LOADING OVERLAY
// ─────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 2,
            ),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
