import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/app_user.dart';
import '../../models/lobby.dart';
import '../../services/lobby_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../lobby/lobby_screen.dart';
import '../custom_category/custom_category_screen.dart';

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
    setState(() {
      _loading = true;
      _error = null;
    });
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
    setState(() {
      _loading = true;
      _error = null;
    });
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

  void _goToCustomCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomCategoryScreen(currentUser: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Blind Ranking',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Ausloggen',
            onPressed: () async {
              await widget.authService.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 4),
            Text(
              widget.user.isGuest ? 'Du spielst als Gast' : 'Eingeloggt',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 36),

            // Lobby erstellen
            _bigCard(
              onTap: _loading ? null : _createLobby,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryVariant],
              ),
              icon: Icons.add_circle_outline,
              title: 'Lobby erstellen',
              subtitle: 'Starte ein neues Spiel als Host',
            ),

            const SizedBox(height: 14),

            // Eigene Kategorien Card
            _bigCard(
              onTap: _goToCustomCategories,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF8C42)],
              ),
              icon: Icons.auto_awesome,
              title: 'Eigene Kategorien',
              subtitle: 'Erstelle deine eigenen Listen & Items',
              badge: 'NEU',
            ),

            const SizedBox(height: 28),

            // Lobby beitreten
            const Text('Lobby beitreten',
                style: TextStyle(
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
                      prefixIcon:
                          Icon(Icons.vpn_key, color: AppColors.textSecondary),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9a-z]')),
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onSubmitted: (_) => _joinLobby(),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _joinLobby,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                    ),
                    child: const Text('Join',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13))),
                  ],
                ),
              ),
            ],

            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bigCard({
    required VoidCallback? onTap,
    required LinearGradient gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(badge,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                  Text(title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 36),
          ],
        ),
      ),
    );
  }
}
