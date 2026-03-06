import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/game_providers.dart';
import '../../widgets/common/common_widgets.dart';

class JoinLobbyScreen extends ConsumerStatefulWidget {
  const JoinLobbyScreen({super.key});

  @override
  ConsumerState<JoinLobbyScreen> createState() => _JoinLobbyScreenState();
}

class _JoinLobbyScreenState extends ConsumerState<JoinLobbyScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinByCode(String code) async {
    if (code.trim().isEmpty) {
      setState(() => _error = 'Bitte einen Lobby-Code eingeben.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lobby = await ref
          .read(lobbyServiceProvider)
          .getLobby(code.trim().toUpperCase());

      if (lobby == null) {
        setState(() => _error = 'Lobby nicht gefunden.');
        return;
      }
      if (!lobby.isOpen) {
        setState(() => _error = 'Diese Lobby ist bereits gestartet.');
        return;
      }

      final user = await ref.read(authServiceProvider).getCurrentUserModel();
      if (user == null) return;

      await ref.read(lobbyServiceProvider).joinLobby(
            lobbyId: lobby.lobbyId,
            user: user,
          );

      if (mounted) context.go('/lobby/${lobby.lobbyId}');
    } catch (e) {
      setState(() => _error = 'Fehler: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openQrInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'QR-Code Scanner',
          style: TextStyle(
            fontFamily: 'Cinzel',
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
        content: const Text(
          'Bitte gib den 6-stelligen Lobby-Code manuell ein.\n\n'
          'Der QR-Scanner ist in der nativen App (iOS/Android) verfügbar.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.gold, fontFamily: 'Cinzel'),
            ),
          ),
        ],
      ),
    );
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
                  Text('LOBBY BEITRETEN',
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // QR button
                    GestureDetector(
                      onTap: _openQrInfo,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.border, width: 1.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_scanner,
                                color: AppColors.gold, size: 60),
                            const SizedBox(height: 10),
                            Text(
                              kIsWeb
                                  ? 'QR-CODE\n(NUR APP)'
                                  : 'QR-CODE\nSCANNEN',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: AppColors.gold),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('ODER',
                              style: Theme.of(context).textTheme.labelMedium),
                        ),
                        const Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),

                    const SizedBox(height: 32),

                    TextField(
                      controller: _codeCtrl,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Cinzel',
                        fontSize: 24,
                        letterSpacing: 6,
                      ),
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                      onSubmitted: (val) => _joinByCode(val),
                      decoration: const InputDecoration(
                        hintText: 'ABC123',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontFamily: 'Cinzel',
                          fontSize: 24,
                          letterSpacing: 6,
                        ),
                        counterText: '',
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.blood.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppColors.blood.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_outlined,
                                color: AppColors.blood, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: const TextStyle(
                                      color: AppColors.blood, fontSize: 13)),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().shakeX(),
                    ],

                    const SizedBox(height: 24),

                    MafiaButton(
                      label: 'Beitreten',
                      isDestructive: true,
                      isLoading: _loading,
                      onPressed: () => _joinByCode(_codeCtrl.text),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.textMuted, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Den 6-stelligen Code bekommst du vom Spielführer der die Lobby erstellt hat.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),
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
