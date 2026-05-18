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

  const LobbyScreen({super.key, required this.lobby, required this.currentUser, required this.lobbyService});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late Lobby _lobby;
  List<LobbyPlayer> _players = [];
  List<Category> _level0 = [];
  List<SubCategory> _level1 = [];
  List<SubCategory> _level2 = [];
  Category? _selected0;
  SubCategory? _selected1;
  SubCategory? _selected2;
  ListSize _selectedListSize = ListSize.top10;
  final _categoryService = CategoryService();
  final _gameService = GameService();
  bool _starting = false;
  bool _navigating = false;

  bool get isHost => _lobby.hostId == widget.currentUser.id;
  String? get _activeCategoryId => _selected0?.id;
  String? get _activeSubCategoryId => _selected2?.id ?? _selected1?.id;

  String get _selectionLabel {
    if (_selected0 == null) return '';
    if (_selected1 == null) return _selected0!.name;
    if (_selected2 == null) return '${_selected0!.name} › ${_selected1!.name}';
    return '${_selected0!.name} › ${_selected1!.name} › ${_selected2!.name}';
  }

  @override
  void initState() {
    super.initState();
    _lobby = widget.lobby;
    _selectedListSize = _lobby.listSize;
    _loadLevel0();
  }

  Future<void> _loadLevel0() async {
    final cats = await _categoryService.fetchMainCategories();
    setState(() => _level0 = cats);
  }

  Future<void> _onLevel0Selected(Category? cat) async {
    if (cat == null) return;
    setState(() { _selected0 = cat; _selected1 = null; _selected2 = null; _level1 = []; _level2 = []; });
    await widget.lobbyService.updateLobbySettings(lobbyId: _lobby.id, categoryId: cat.id, subCategoryId: null, clearSubCategory: true);
    final subs = await _categoryService.fetchSubCategories(cat.id);
    setState(() => _level1 = subs);
  }

  Future<void> _onLevel1Selected(SubCategory? sub) async {
    setState(() { _selected1 = sub; _selected2 = null; _level2 = []; });
    await widget.lobbyService.updateLobbySettings(lobbyId: _lobby.id, subCategoryId: sub?.id, clearSubCategory: true);
    if (sub != null) {
      final subsubs = await _categoryService.fetchSubCategories(sub.id);
      setState(() => _level2 = subsubs);
    }
  }

  Future<void> _onLevel2Selected(SubCategory? sub) async {
    setState(() => _selected2 = sub);
    await widget.lobbyService.updateLobbySettings(lobbyId: _lobby.id, subCategoryId: sub?.id, clearSubCategory: true);
  }

  Future<void> _onListSizeSelected(ListSize? size) async {
    if (size == null) return;
    setState(() => _selectedListSize = size);
    await widget.lobbyService.updateLobbySettings(lobbyId: _lobby.id, listSize: size);
  }

  Future<void> _startGame() async {
    if (_activeCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte wähle zuerst eine Kategorie'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _starting = true);
    try {
      final items = await _categoryService.fetchItems(categoryId: _activeCategoryId!, subCategoryId: _activeSubCategoryId);
      if (items.length < 5) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zu wenige Items (mind. 5)')));
        return;
      }
      await widget.lobbyService.updateLobbyStatus(lobbyId: _lobby.id, status: LobbyStatus.playing);
      final session = await _gameService.startSession(
        lobbyId: _lobby.id,
        allItemIds: items.map((e) => e.id).toList(),
        listSize: _selectedListSize,
      );
      if (mounted) _navigateToGame(session);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  void _navigateToGame(dynamic session) {
    if (_navigating) return;
    _navigating = true;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => GameScreen(
        session: session, lobby: _lobby, currentUser: widget.currentUser,
        gameService: _gameService, categoryService: _categoryService, lobbyService: widget.lobbyService,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lobby')),
      body: StreamBuilder<List<LobbyPlayer>>(
        stream: widget.lobbyService.watchPlayers(_lobby.id),
        builder: (context, playersSnap) {
          _players = playersSnap.data ?? [];
          return StreamBuilder<Map<String, dynamic>?>(
            stream: widget.lobbyService.watchLobby(_lobby.id),
            builder: (context, lobbySnap) {
              if (!isHost && lobbySnap.hasData && lobbySnap.data != null &&
                  lobbySnap.data!['status'] == 'playing' && !_navigating) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!mounted || _navigating) return;
                  final session = await _gameService.fetchActiveSession(_lobby.id);
                  if (session != null && mounted) _navigateToGame(session);
                });
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCodeCard(),
                    const SizedBox(height: 20),
                    const Text('Spieler', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ..._players.map(_buildPlayerTile),
                    const SizedBox(height: 20),
                    if (isHost) ...[
                      _buildSettings(),
                      const SizedBox(height: 16),
                      if (_selected0 != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_selectionLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
                          ]),
                        ),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _starting ? null : _startGame,
                          icon: _starting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow),
                          label: Text(_starting ? 'Startet...' : 'Spiel starten'),
                        ),
                      ),
                    ] else
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                        child: const Column(children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 14),
                          Text('Warte auf den Host…', style: TextStyle(color: AppColors.textSecondary)),
                        ]),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Spieleinstellungen', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          DropdownButtonFormField<Category>(
            decoration: const InputDecoration(labelText: 'Kategorie wählen'),
            value: _selected0,
            hint: const Text('Kategorie wählen…', style: TextStyle(color: AppColors.textSecondary)),
            items: _level0.map((c) => DropdownMenuItem(value: c, child: Text(c.name, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
            onChanged: _onLevel0Selected,
            dropdownColor: AppColors.surface,
          ),
          if (_level1.isNotEmpty) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<SubCategory?>(
              decoration: const InputDecoration(labelText: 'Unterkategorie (optional)'),
              value: _selected1,
              items: [
                const DropdownMenuItem<SubCategory?>(value: null, child: Text('Alle', style: TextStyle(color: AppColors.textPrimary))),
                ..._level1.map((s) => DropdownMenuItem<SubCategory?>(value: s, child: Text(s.name, style: const TextStyle(color: AppColors.textPrimary)))),
              ],
              onChanged: _onLevel1Selected,
              dropdownColor: AppColors.surface,
            ),
          ],
          if (_level2.isNotEmpty) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<SubCategory?>(
              decoration: const InputDecoration(labelText: 'Genauer eingrenzen (optional)'),
              value: _selected2,
              items: [
                const DropdownMenuItem<SubCategory?>(value: null, child: Text('Alle', style: TextStyle(color: AppColors.textPrimary))),
                ..._level2.map((s) => DropdownMenuItem<SubCategory?>(value: s, child: Text(s.name, style: const TextStyle(color: AppColors.textPrimary)))),
              ],
              onChanged: _onLevel2Selected,
              dropdownColor: AppColors.surface,
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<ListSize>(
            decoration: const InputDecoration(labelText: 'Listen Größe'),
            value: _selectedListSize,
            items: const [
              DropdownMenuItem(value: ListSize.top5, child: Text('Top 5', style: TextStyle(color: AppColors.textPrimary))),
              DropdownMenuItem(value: ListSize.top10, child: Text('Top 10', style: TextStyle(color: AppColors.textPrimary))),
              DropdownMenuItem(value: ListSize.tierList, child: Text('Tier List (S–F)', style: TextStyle(color: AppColors.textPrimary))),
            ],
            onChanged: _onListSizeSelected,
            dropdownColor: AppColors.surface,
          ),
        ]),
      ),
    );
  }

  Widget _buildCodeCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        const Text('Lobby Code', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_lobby.code, style: const TextStyle(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 8)),
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.textSecondary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _lobby.code));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code kopiert!')));
            },
          ),
        ]),
      ]),
    );
  }

  Widget _buildPlayerTile(LobbyPlayer player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Text(player.displayName[0].toUpperCase(), style: const TextStyle(color: AppColors.primary)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(player.displayName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
        if (player.isHost)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Text('Host', style: TextStyle(color: AppColors.accent, fontSize: 12)),
          ),
      ]),
    );
  }
}
