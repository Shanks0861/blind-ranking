import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/lobby.dart';
import '../../models/game_session.dart';
import '../../models/category.dart';
import '../../services/game_service.dart';
import '../../services/category_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/ranking_slot_widget.dart';
import '../../widgets/item_reveal_dialog.dart';
import '../final/final_screen.dart';

class GameScreen extends StatefulWidget {
  final GameSession session;
  final Lobby lobby;
  final AppUser currentUser;
  final GameService gameService;
  final CategoryService categoryService;

  const GameScreen({
    super.key,
    required this.session,
    required this.lobby,
    required this.currentUser,
    required this.gameService,
    required this.categoryService,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameSession _session;
  GameItem? _currentItem;
  final Map<int, RankingEntry> _myRankings = {}; // position → entry
  bool _showRevealDialog = true;
  bool _confirmed = false;
  int? _selectedSlot;
  List<GameItem> _loadedItems = [];

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
    setState(() {
      _currentItem = item;
      _showRevealDialog = true;
      _confirmed = false;
      _selectedSlot = null;
    });
    if (item != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ItemRevealDialog(
          item: item,
          onContinue: () {
            Navigator.of(context).pop();
            setState(() => _showRevealDialog = false);
          },
        ),
      );
    }
  }

  int get _slotCount {
    switch (widget.lobby.listSize) {
      case ListSize.top5: return 5;
      case ListSize.top10: return 10;
      case ListSize.tierList: return 6; // S A B C D F
    }
  }

  bool get isTierList => widget.lobby.listSize == ListSize.tierList;

  Future<void> _confirmSelection() async {
    if (_selectedSlot == null) return;
    if (_currentItem == null) return;

    final entry = RankingEntry(
      itemId: _currentItem!.id,
      position: _selectedSlot!,
      tier: isTierList ? AppConstants.tiers[_selectedSlot! - 1] : null,
    );

    setState(() {
      _myRankings[_selectedSlot!] = entry;
      _confirmed = true;
    });

    await widget.gameService.saveRanking(
      sessionId: _session.id,
      userId: widget.currentUser.id,
      displayName: widget.currentUser.displayName,
      entries: _myRankings.values.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_session.currentItemIndex + 1) / _session.itemQueue.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Runde ${_session.currentItemIndex + 1} / ${_session.itemQueue.length}',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
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
                setState(() => _session = updated);
                _loadCurrentItem();
              });
            }
            if (updated.phase == GamePhase.finalPhase) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FinalScreen(
                      session: updated,
                      currentUser: widget.currentUser,
                      gameService: widget.gameService,
                      categoryService: widget.categoryService,
                      isHost: widget.lobby.hostId == widget.currentUser.id,
                    ),
                  ),
                );
              });
            }
          }

          return Column(
            children: [
              // Aktuelles Item Info
              if (_currentItem != null && !_showRevealDialog)
                _buildCurrentItemBar(),
              // Ranking Liste
              Expanded(
                child: isTierList
                    ? _buildTierListView()
                    : _buildRankingListView(),
              ),
              // Bestätigen Button
              if (!_confirmed && !_showRevealDialog)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedSlot != null ? _confirmSelection : null,
                      child: const Text('Platzierung bestätigen'),
                    ),
                  ),
                ),
              if (_confirmed)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Bestätigt! Warte auf andere Spieler…',
                            style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              // Host: Nächstes Item / Reveal / Finale
              if (widget.lobby.hostId == widget.currentUser.id && _confirmed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _handleHostNext,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                      ),
                      child: Text(_session.isLastItem ? 'Finale starten' : 'Nächstes Item'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
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

  Widget _buildCurrentItemBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          if (_currentItem?.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _currentItem!.imageUrl!,
                width: 48, height: 48, fit: BoxFit.cover,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jetzt platzieren:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(_currentItem!.name, style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
              ],
            ),
          ),
          if (_selectedSlot != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isTierList ? AppConstants.tiers[_selectedSlot! - 1] : '#$_selectedSlot',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRankingListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _slotCount,
      itemBuilder: (_, i) {
        final pos = i + 1;
        final entry = _myRankings[pos];
        final item = entry != null
            ? _loadedItems.where((it) => it.id == entry.itemId).firstOrNull
            : null;

        return RankingSlotWidget(
          position: pos,
          entry: entry,
          item: item,
          isSelected: _selectedSlot == pos,
          onTap: _confirmed || entry != null ? null : () {
            setState(() => _selectedSlot = pos);
          },
        );
      },
    );
  }

  Widget _buildTierListView() {
    const tiers = AppConstants.tiers;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tiers.length,
      itemBuilder: (_, i) {
        final tier = tiers[i];
        final pos = i + 1;
        final entry = _myRankings[pos];
        final items = entry != null
            ? _loadedItems.where((it) => it.id == entry.itemId).toList()
            : <GameItem>[];

        return TierRowWidget(
          tier: tier,
          items: items,
          isSelected: _selectedSlot == pos,
          onTap: _confirmed || entry != null ? null : () {
            setState(() => _selectedSlot = pos);
          },
        );
      },
    );
  }
}

// ignore: non_constant_identifier_names
class AppConstants {
  static const tiers = ['S', 'A', 'B', 'C', 'D', 'F'];
}
