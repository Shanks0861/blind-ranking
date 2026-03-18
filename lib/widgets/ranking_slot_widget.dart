import 'package:flutter/material.dart';
import '../models/game_session.dart';
import '../models/category.dart';
import '../utils/app_theme.dart';

class RankingSlotWidget extends StatelessWidget {
  final int position;
  final RankingEntry? entry;
  final GameItem? item;
  final bool isSelected;
  final VoidCallback? onTap;

  const RankingSlotWidget({
    super.key,
    required this.position,
    this.entry,
    this.item,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.rankColor(position);
    final isEmpty = entry == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.3)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Position Badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$position',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Item Info oder leer
              Expanded(
                child: isEmpty
                    ? Text(
                        'Leer',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Row(
                        children: [
                          if (item?.imageUrl != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                item!.imageUrl!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported, size: 36),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Text(
                              item?.name ?? '...',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TierRowWidget extends StatelessWidget {
  final String tier;
  final List<GameItem> items;
  final VoidCallback? onTap;
  final bool isSelected;

  const TierRowWidget({
    super.key,
    required this.tier,
    required this.items,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.tierColors[tier] ?? Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(8),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                tier,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: items.isEmpty
                    ? const Text(
                        'Noch leer…',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    : Wrap(
                        spacing: 6,
                        children: items
                            .map(
                              (item) => Chip(
                                label: Text(item.name,
                                    style: const TextStyle(fontSize: 12)),
                                backgroundColor: AppColors.surfaceVariant,
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
