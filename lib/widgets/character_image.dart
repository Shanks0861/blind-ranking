import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CharacterImage extends StatelessWidget {
  final String? storedUrl;
  final String characterName;
  final double size;
  final BoxFit fit;

  const CharacterImage({
    super.key,
    required this.storedUrl,
    required this.characterName,
    required this.size,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final url = storedUrl;

    if (url == null || url.isEmpty) {
      return _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: fit,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            width: size,
            height: size,
            color: AppColors.surfaceVariant,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.primary,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.person_outline,
        color: AppColors.textSecondary,
        size: size * 0.5,
      ),
    );
  }
}
