import 'package:flutter/material.dart';
import '../models/category.dart';
import 'character_image.dart';
import '../utils/app_theme.dart';

class ItemRevealDialog extends StatefulWidget {
  final GameItem item;
  final VoidCallback onContinue;

  const ItemRevealDialog({
    super.key,
    required this.item,
    required this.onContinue,
  });

  @override
  State<ItemRevealDialog> createState() => _ItemRevealDialogState();
}

class _ItemRevealDialogState extends State<ItemRevealDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: const Text(
                    '✨ Neues Item!',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Bild
                CharacterImage(
                  storedUrl: widget.item.imageUrl,
                  characterName: widget.item.name,
                  size: 180,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  widget.item.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onContinue,
                    child: const Text('Platzieren'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
