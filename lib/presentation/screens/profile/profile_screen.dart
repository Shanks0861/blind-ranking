import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/game_models.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

const List<Map<String, String>> kPresetAvatars = [
  {'emoji': '🕵️', 'label': 'Detektiv'},
  {'emoji': '🔪', 'label': 'Mafia'},
  {'emoji': '👨‍🌾', 'label': 'Bürger'},
  {'emoji': '🏹', 'label': 'Jäger'},
  {'emoji': '🎭', 'label': 'Schauspieler'},
  {'emoji': '🦊', 'label': 'Fuchs'},
  {'emoji': '🐺', 'label': 'Wolf'},
  {'emoji': '🦁', 'label': 'Löwe'},
  {'emoji': '🐍', 'label': 'Schlange'},
  {'emoji': '🦅', 'label': 'Adler'},
  {'emoji': '🎩', 'label': 'Zauberer'},
  {'emoji': '💀', 'label': 'Schatten'},
  {'emoji': '🤺', 'label': 'Duellant'},
  {'emoji': '🧠', 'label': 'Stratege'},
  {'emoji': '👁️', 'label': 'Auge'},
  {'emoji': '🗡️', 'label': 'Assassine'},
];

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  String? _selectedAvatar;
  bool _loading = false;
  bool _saved = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserModelProvider).value;
      if (user != null) {
        _nameCtrl.text = user.displayName;
        if (user.profileImage != null &&
            kPresetAvatars.any((a) => a['emoji'] == user.profileImage)) {
          setState(() => _selectedAvatar = user.profileImage);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name darf nicht leer sein.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _saved = false;
    });
    try {
      final user = ref.read(currentUserModelProvider).value;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .update({
        'displayName': _nameCtrl.text.trim(),
        'profileImage': _selectedAvatar,
      });
      await ref
          .read(authServiceProvider)
          .currentUser
          ?.updateDisplayName(_nameCtrl.text.trim());
      ref.invalidate(currentUserModelProvider);
      setState(() => _saved = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _saved = false);
    } catch (e) {
      setState(() => _error = 'Fehler beim Speichern.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserModelProvider);
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
                  Text('MEIN PROFIL',
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            Expanded(
              child: userAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.gold)),
                error: (e, _) => Center(child: Text('Fehler: $e')),
                data: (user) {
                  if (user == null) return const SizedBox.shrink();
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar preview
                        Center(
                          child: Column(
                            children: [
                              _buildAvatarPreview(user),
                              const SizedBox(height: 12),
                              Text(user.displayName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                              Text(
                                ref
                                        .read(authServiceProvider)
                                        .currentUser
                                        ?.email ??
                                    '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms),

                        const OrnamentDivider(),

                        // Name field
                        _sectionLabel('ANZEIGENAME'),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          maxLength: 20,
                          decoration: const InputDecoration(
                            labelText: 'Dein Name im Spiel',
                            prefixIcon: Icon(Icons.person_outline,
                                color: AppColors.textMuted, size: 20),
                            counterStyle: TextStyle(color: AppColors.textMuted),
                          ),
                        ).animate().fadeIn(delay: 100.ms),

                        const SizedBox(height: 28),

                        // Avatar grid
                        _sectionLabel('AVATAR WÄHLEN'),
                        const SizedBox(height: 4),
                        Text('Wähle deinen Charakter für das Spiel',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 16),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: kPresetAvatars.length,
                          itemBuilder: (context, index) {
                            final avatar = kPresetAvatars[index];
                            final isSelected =
                                _selectedAvatar == avatar['emoji'];
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedAvatar = avatar['emoji']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.gold.withOpacity(0.15)
                                      : AppColors.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.gold
                                        : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(avatar['emoji']!,
                                        style: const TextStyle(fontSize: 30)),
                                    const SizedBox(height: 4),
                                    Text(
                                      avatar['label']!,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isSelected
                                            ? AppColors.gold
                                            : AppColors.textMuted,
                                        fontFamily: 'Cinzel',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(
                                    delay: Duration(milliseconds: index * 40))
                                .scale(begin: const Offset(0.8, 0.8));
                          },
                        ),

                        const SizedBox(height: 16),

                        // Initialen-Avatar option
                        GestureDetector(
                          onTap: () => setState(() => _selectedAvatar = null),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _selectedAvatar == null
                                  ? AppColors.blood.withOpacity(0.1)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedAvatar == null
                                    ? AppColors.blood
                                    : AppColors.border,
                                width: _selectedAvatar == null ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.surfaceElevated,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.displayName.isNotEmpty
                                          ? user.displayName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontFamily: 'Cinzel',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Initialen-Avatar',
                                          style: TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          )),
                                      Text('Erster Buchstabe deines Namens',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                          )),
                                    ],
                                  ),
                                ),
                                if (_selectedAvatar == null)
                                  const Icon(Icons.check_circle,
                                      color: AppColors.blood, size: 20),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 700.ms),

                        const SizedBox(height: 32),

                        if (_error != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.blood.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: AppColors.blood.withOpacity(0.4)),
                            ),
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: AppColors.blood, fontSize: 13)),
                          ).animate().fadeIn().shakeX(),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _saved
                              ? Container(
                                  key: const ValueKey('saved'),
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.alive.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color:
                                            AppColors.alive.withOpacity(0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline,
                                          color: AppColors.alive, size: 20),
                                      SizedBox(width: 10),
                                      Text('GESPEICHERT',
                                          style: TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.alive,
                                            letterSpacing: 2,
                                          )),
                                    ],
                                  ),
                                )
                              : MafiaButton(
                                  key: const ValueKey('save'),
                                  label: 'Profil speichern',
                                  isDestructive: true,
                                  isLoading: _loading,
                                  onPressed: _saveProfile,
                                ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(UserModel user) {
    final avatar = _selectedAvatar ??
        (user.profileImage != null &&
                kPresetAvatars.any((a) => a['emoji'] == user.profileImage)
            ? user.profileImage
            : null);
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.card,
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
              color: AppColors.gold.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 4),
        ],
      ),
      child: Center(
        child: avatar != null
            ? Text(avatar, style: const TextStyle(fontSize: 42))
            : Text(
                user.displayName.isNotEmpty
                    ? user.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 2,
        ));
  }
}
