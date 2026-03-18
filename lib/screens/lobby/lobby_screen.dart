import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/app_user.dart';
import '../../models/lobby.dart';
import '../../models/category.dart';
import '../../services/lobby_service.dart';
import '../../services/category_service.dart';
import '../../services/game_service.dart';
import '../../utils/app_theme.dart';
import '../game/game_screen.dart';

class LobbyScreen extends StatefulWidget {
  final Lobby lobby;
  final AppUser currentUser;
  final LobbyService lobbyService;

  const LobbyScreen({
    super.key,
    required this.lobby,
    required this.currentUser,
    required this.lobbyService,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late Lobby _lobby;
  List<LobbyPlayer> _players = [];
  List<Category> _categories = [];
  List<SubCategory> _subCategories = [];

  final _categoryService = CategoryService();
  final _gameService = GameService();

  bool get isHost => _lobby.hostId == widget.currentUser.id;

  @override
  void initState() {
    super.initState();
    _lobby = widget.lobby;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _categoryService.fetchMainCategories();
    setState(() => _categories = cats);
  }

  Future<void> _onCategorySelected(Category? cat) async {
    if (cat == null) return;
    await widget.lobbyService.updateLobbySettings(
      lobbyId: _lobby.id,
      categoryId: cat.id,
      subCategoryId: null,
    );
    final subs = await _categoryService.fetchSubCategories(cat.id);
    setState(() => _subCategories = subs);
  }

  Future<void> _startGame() async {
    if (_lobby.categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wähle zuerst eine Kategorie')),
      );
      return;
    }

    final items = await _categoryService.fetchItems(
      categoryId: _lobby.categoryId!,
      subCategoryId: _lobby.subCategoryId,
    );

    if (items.length < 5) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zu wenige Items in dieser Kategorie')),
      );
      return;
    }

    await widget.lobbyService.updateLobbyStatus(
      lobbyId: _lobby.id,
      status: LobbyStatus.playing,
    );

    final session = await _gameService.startSession(
      lobbyId: _lobby.id,
      allItemIds: items.map((e) => e.id).toList(),
      listSize: _lobby.listSize,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            session: session,
            lobby: _lobby,
            currentUser: widget.currentUser,
            gameService: _gameService,
            categoryService: _categoryService,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Lobby'),
      ),
      body: StreamBuilder<List<LobbyPlayer>>(
        stream: widget.lobbyService.watchPlayers(_lobby.id),
        builder: (context, snapshot) {
          _players = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Code anzeigen
                _buildCodeCard(),
                const SizedBox(height: 20),
                // Spieler
                const Text('Spieler', style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 10),
                ..._players.map((p) => _buildPlayerTile(p)),
                const SizedBox(height: 20),
                // Host-Einstellungen
                if (isHost) ...[
                  _buildSettings(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _players.length >= 2 ? _startGame : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Spiel starten'),
                    ),
                  ),
                  if (_players.length < 2)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Mindestens 2 Spieler nötig',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ] else ...[
                  const Center(
                    child: Text(
                      'Warte auf den Host…',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text('Lobby Code', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _lobby.code,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.copy, color: AppColors.textSecondary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _lobby.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code kopiert!')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(LobbyPlayer player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(player.displayName[0].toUpperCase(),
                style: const TextStyle(color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(player.displayName,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
          if (player.isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Host', style: TextStyle(color: AppColors.accent, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spieleinstellungen', style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )),
            const SizedBox(height: 16),
            // Kategorie
            DropdownButtonFormField<Category>(
              decoration: const InputDecoration(labelText: 'Kategorie'),
              value: _categories.where((c) => c.id == _lobby.categoryId).firstOrNull,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: _onCategorySelected,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            if (_subCategories.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<SubCategory>(
                decoration: const InputDecoration(labelText: 'Unterkategorie (optional)'),
                value: _subCategories.where((s) => s.id == _lobby.subCategoryId).firstOrNull,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Alle')),
                  ..._subCategories.map((s) => DropdownMenuItem(value: s, child: Text(s.name))),
                ],
                onChanged: (sub) async {
                  await widget.lobbyService.updateLobbySettings(
                    lobbyId: _lobby.id,
                    subCategoryId: sub?.id,
                  );
                },
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ],
            const SizedBox(height: 12),
            // Listen Größe
            DropdownButtonFormField<ListSize>(
              decoration: const InputDecoration(labelText: 'Listen Größe'),
              value: _lobby.listSize,
              items: const [
                DropdownMenuItem(value: ListSize.top5, child: Text('Top 5')),
                DropdownMenuItem(value: ListSize.top10, child: Text('Top 10')),
                DropdownMenuItem(value: ListSize.tierList, child: Text('Tier List (S–F)')),
              ],
              onChanged: (size) async {
                if (size != null) {
                  await widget.lobbyService.updateLobbySettings(
                    lobbyId: _lobby.id,
                    listSize: size,
                  );
                }
              },
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
