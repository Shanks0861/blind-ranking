import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/app_user.dart';
import '../../models/lobby.dart';
import '../../services/lobby_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../lobby/lobby_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  final LobbyService lobbyService;
  final AuthService authService;

  const HomeScreen({
    super.key,
    required this.user,
    required this.lobbyService,
    required this.authService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _createLobby() async {
    setState(() { _loading = true; _error = null; });
    try {
      final lobby = await widget.lobbyService.createLobby(
        hostId: widget.user.id,
        hostDisplayName: widget.user.displayName,
      );
      if (mounted) _goToLobby(lobby);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _joinLobby() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _error = 'Bitte gib einen 6-stelligen Code ein');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final lobby = await widget.lobbyService.joinLobby(
        code: code,
        userId: widget.user.id,
        displayName: widget.user.displayName,
      );
      if (mounted) _goToLobby(lobby);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _goToLobby(Lobby lobby) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LobbyScreen(
          lobby: lobby,
          currentUser: widget.user,
          lobbyService: widget.lobbyService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Blind Ranking', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.authService.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Begrüßung
            Text(
              'Hallo, ${widget.user.displayName}! 👋',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.user.isGuest ? 'Du spielst als Gast' : 'Eingeloggt',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),

            // Lobby erstellen
            GestureDetector(
              onTap: _loading ? null : _createLobby,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryVariant],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.add_circle_outline, color: Colors.white, size: 32),
                    const SizedBox(height: 12),
                    const Text('Lobby erstellen', style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 4),
                    Text('Starte ein neues Spiel als Host',
                        style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Lobby beitreten
            const Text('Lobby beitreten', style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Code eingeben…',
                      prefixIcon: Icon(Icons.vpn_key, color: AppColors.textSecondary),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9a-z]')),
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _joinLobby,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  child: const Text('Join'),
                ),
              ],
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            if (_loading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
