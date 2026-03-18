import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/lobby.dart';
import '../../models/game_session.dart';
import '../../models/category.dart';
import '../../services/game_service.dart';
import '../../services/category_service.dart';
import '../../services/lobby_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/item_reveal_dialog.dart';
import '../../widgets/character_image.dart';
import '../final/final_screen.dart';

const List<String> kTiers = ['S', 'A', 'B', 'C', 'D', 'F'];

class GameScreen extends StatefulWidget {
  final GameSession session;
  final Lobby lobby;
  final AppUser currentUser;
  final GameService gameService;
  final CategoryService categoryService;
  final LobbyService lobbyService;

  const GameScreen({
    super.key,
    required this.session,
    required this.lobby,
    required this.currentUser,
    required this.gameService,
    required this.categoryService,
    required this.lobbyService,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameSession _session;
  GameItem? _currentItem;
  final Map<int, GameItem> _placedItems = {};
  bool _revealShowing = false;
  bool _confirmed = false;
  int? _selectedSlot;
  bool _navigating = false;

  bool get isHost => widget.lobby.hostId == widget.currentUser.id;
  bool get isTierList => widget.lobby.listSize == ListSize.tierList;
  int get slotCount {
    switch (widget.lobby.listSize) {
      case ListSize.top5:
        return 5;
      case ListSize.top10:
        return 10;
      case ListSize.tierList:
        return 6;
    }
  }

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _loadCurrentItem();
  }

  Future<void> _loadCurrentItem() async {
    final id = _session.currentItemId;
    if (id == null) return;
    final item = await widget.categoryService.fetchItemById(id);
    if (!mounted) return;
    setState(() {
      _currentItem = item;
      _confirmed = false;
      _selectedSlot = null;
      _revealShowing = true;
    });
    if (item != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ItemRevealDialog(
          item: item,
          onContinue: () {
            Navigator.of(context).pop();
            if (mounted) setState(() => _revealShowing = false);
          },
        ),
      );
    }
  }

  Future<void> _confirmSelection() async {
    if (_selectedSlot == null || _currentItem == null) return;
    setState(() {
      _placedItems[_selectedSlot!] = _currentItem!;
      _confirmed = true;
    });
    await widget.gameService.saveRanking(
      sessionId: _session.id,
      userId: widget.currentUser.id,
      displayName: widget.currentUser.displayName,
      entries: _placedItems.entries
          .map((e) => RankingEntry(
                itemId: e.value.id,
                position: e.key,
                tier: isTierList ? kTiers[e.key - 1] : null,
              ))
          .toList(),
    );
  }

  Future<void> _handleHostNext() async {
    if (_session.isLastItem) {
      await widget.gameService.advancePhase(
        sessionId: _session.id,
        newPhase: GamePhase.finalPhase,
      );
    } else {
      await widget.gameService.nextItem(
        _session.id,
        _session.currentItemIndex + 1,
      );
    }
  }

  void _goToFinal(GameSession session) {
    if (_navigating) return;
    _navigating = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FinalScreen(
          session: session,
          currentUser: widget.currentUser,
          gameService: widget.gameService,
          categoryService: widget.categoryService,
          lobbyService: widget.lobbyService,
          lobby: widget.lobby,
          isHost: isHost,
          myPlacedItems: _placedItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
            'Runde ${_session.currentItemIndex + 1} / ${_session.itemQueue.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_session.currentItemIndex + 1) / _session.itemQueue.length,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: widget.gameService.watchSession(_session.id),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final updated = GameSession.fromMap(snapshot.data!);
            if (updated.currentItemIndex != _session.currentItemIndex) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() => _session = updated);
                _loadCurrentItem();
              });
            }
            if (updated.phase == GamePhase.finalPhase && !_navigating) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _goToFinal(updated);
              });
            }
          }

          return Column(
            children: [
              if (_currentItem != null && !_revealShowing)
                _buildCurrentItemBar(),
              Expanded(
                child: isTierList ? _buildTierList() : _buildRankingList(),
              ),
              if (!_confirmed && !_revealShowing)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _selectedSlot != null ? _confirmSelection : null,
                      child: Text(
                        _selectedSlot != null
                            ? 'Auf Platz ${isTierList ? kTiers[_selectedSlot! - 1] : _selectedSlot} bestätigen'
                            : 'Slot auswählen',
                      ),
                    ),
                  ),
                ),
              if (_confirmed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text('Platziert! Warte auf andere…',
                            style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              if (isHost && _confirmed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _handleHostNext,
                      icon: Icon(
                          _session.isLastItem ? Icons.flag : Icons.skip_next),
                      label: Text(_session.isLastItem
                          ? 'Finale starten'
                          : 'Nächstes Item'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                      ),
                    ),
                  ),
                ),
              if (!isHost && _confirmed)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text('Warte bis der Host weitermacht…',
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentItemBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          _itemImage(_currentItem, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jetzt platzieren',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                Text(_currentItem!.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17)),
              ],
            ),
          ),
          if (_selectedSlot != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isTierList ? kTiers[_selectedSlot! - 1] : '#$_selectedSlot',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRankingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: slotCount,
      itemBuilder: (_, i) {
        final pos = i + 1;
        final placed = _placedItems[pos];
        final isSelected = _selectedSlot == pos;
        final color = AppColors.rankColor(pos);
        return GestureDetector(
          onTap: (_confirmed || placed != null)
              ? null
              : () {
                  setState(() => _selectedSlot = pos);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.15)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: Text('$pos',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  if (placed != null) ...[
                    _itemImage(placed, size: 38),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(placed.name,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ] else
                    Expanded(
                      child: Text(
                        isSelected ? '← Hier platzieren' : 'Leer',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTierList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: kTiers.length,
      itemBuilder: (_, i) {
        final tier = kTiers[i];
        final pos = i + 1;
        final placed = _placedItems[pos];
        final isSelected = _selectedSlot == pos;
        final color = AppColors.tierColors[tier] ?? Colors.grey;
        return GestureDetector(
          onTap: (_confirmed || placed != null)
              ? null
              : () {
                  setState(() => _selectedSlot = pos);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius:
                        const BorderRadius.horizontal(left: Radius.circular(8)),
                  ),
                  alignment: Alignment.center,
                  child: Text(tier,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ),
                const SizedBox(width: 12),
                if (placed != null) ...[
                  _itemImage(placed, size: 38),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(placed.name,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                  ),
                ] else
                  Expanded(
                    child: Text(
                      isSelected ? '← Hier platzieren' : 'Leer',
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _itemImage(GameItem? item, {required double size}) {
    if (item == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.image_not_supported,
            color: AppColors.textSecondary, size: 20),
      );
    }
    return CharacterImage(
      storedUrl: item.imageUrl,
      characterName: item.name,
      size: size,
    );
  }
}
