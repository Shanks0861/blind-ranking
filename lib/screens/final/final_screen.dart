import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/lobby.dart';
import '../../models/category.dart';
import '../../services/game_service.dart';
import '../../services/category_service.dart';
import '../../services/lobby_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/character_image.dart';
import '../lobby/lobby_screen.dart';

class FinalScreen extends StatefulWidget {
  final GameSession session;
  final AppUser currentUser;
  final GameService gameService;
  final CategoryService categoryService;
  final LobbyService lobbyService;
  final Lobby lobby;
  final bool isHost;
  final Map<int, GameItem> myPlacedItems;

  const FinalScreen({
    super.key,
    required this.session,
    required this.currentUser,
    required this.gameService,
    required this.categoryService,
    required this.lobbyService,
    required this.lobby,
    required this.isHost,
    required this.myPlacedItems,
  });

  @override
  State<FinalScreen> createState() => _FinalScreenState();
}

class _FinalScreenState extends State<FinalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<PlayerRanking> _rankings = [];
  Map<String, GameItem> _itemsById = {};
  Map<String, int> _voteResults = {};
  bool _hasVoted = false;
  bool _votingOpen = false;
  bool _loading = true;
  bool _restarting = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final rankings = await widget.gameService.fetchAllRankings(widget.session.id);
    final allIds = rankings.expand((r) => r.entries.map((e) => e.itemId)).toSet().toList();
    final items = await widget.categoryService.fetchItemsByIds(allIds);
    for (final item in widget.myPlacedItems.values) {
      if (!items.any((i) => i.id == item.id)) items.add(item);
    }
    setState(() {
      _rankings = rankings;
      _itemsById = {for (final i in items) i.id: i};
      _loading = false;
    });
  }

  Future<void> _openVoting() async {
    await widget.gameService.advancePhase(sessionId: widget.session.id, newPhase: GamePhase.voting);
    setState(() => _votingOpen = true);
  }

  Future<void> _vote(String votedForUserId) async {
    if (_hasVoted) return;
    await widget.gameService.submitVote(
      sessionId: widget.session.id,
      voterId: widget.currentUser.id,
      votedForUserId: votedForUserId,
    );
    final results = await widget.gameService.fetchVoteResults(widget.session.id);
    setState(() { _voteResults = results; _hasVoted = true; });
  }

  Future<void> _restartGame() async {
    setState(() => _restarting = true);
    await widget.gameService.advancePhase(sessionId: widget.session.id, newPhase: GamePhase.done);
    await widget.lobbyService.updateLobbyStatus(lobbyId: widget.lobby.id, status: LobbyStatus.waiting);
    if (mounted) _goToLobby();
  }

  void _goToLobby() {
    if (_navigating) return;
    _navigating = true;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LobbyScreen(
          lobby: widget.lobby,
          currentUser: widget.currentUser,
          lobbyService: widget.lobbyService,
        ),
      ),
      (route) => false,
    );
  }

  String? get _winnerId {
    if (_voteResults.isEmpty) return null;
    return _voteResults.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🏁 Finale'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [Tab(text: 'Meine Liste'), Tab(text: 'Alle Rankings')],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: widget.gameService.watchVotes(widget.session.id),
              builder: (context, voteSnap) {
                final voteMap = <String, int>{};
                for (final v in voteSnap.data ?? []) {
                  final uid = v['voted_for_user_id'] as String;
                  voteMap[uid] = (voteMap[uid] ?? 0) + 1;
                }
                return StreamBuilder<Map<String, dynamic>?>(
                  stream: widget.gameService.watchSession(widget.session.id),
                  builder: (context, sessionSnap) {
                    if (sessionSnap.hasData && sessionSnap.data != null) {
                      final phase = sessionSnap.data!['phase'] as String?;
                      if (phase == 'voting' && !_votingOpen) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _votingOpen = true);
                        });
                      }
                      if (phase == 'done' && !_navigating) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) _goToLobby();
                        });
                      }
                    }
                    return TabBarView(
                      controller: _tabCtrl,
                      children: [_buildMyList(), _buildAllRankings(voteMap)],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildMyList() {
    final sorted = widget.myPlacedItems.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    if (sorted.isEmpty) return const Center(child: Text('Keine platzierten Items', style: TextStyle(color: AppColors.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final pos = sorted[i].key;
        final item = sorted[i].value;
        final color = AppColors.rankColor(pos);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Container(
                width: 52, height: 70,
                decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.horizontal(left: Radius.circular(13))),
                alignment: Alignment.center,
                child: Text('$pos', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              const SizedBox(width: 14),
              CharacterImage(storedUrl: item.imageUrl, characterName: item.name, size: 52),
              const SizedBox(width: 14),
              Expanded(child: Text(item.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllRankings(Map<String, int> voteMap) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_winnerId != null) ...[_buildWinnerBanner(voteMap), const SizedBox(height: 16)],
          SizedBox(
            height: 420,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _rankings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _buildPlayerColumn(_rankings[i], voteMap),
            ),
          ),
          const SizedBox(height: 24),
          if (widget.isHost && !_votingOpen)
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(onPressed: _openVoting, icon: const Icon(Icons.how_to_vote), label: const Text('Voting starten')),
            ),
          if (_votingOpen && !_hasVoted) _buildVotingButtons(),
          if (_hasVoted) _buildVoteResults(voteMap),
          const SizedBox(height: 24),
          if (widget.isHost)
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton.icon(
                onPressed: _restarting ? null : _restartGame,
                icon: _restarting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh),
                label: Text(_restarting ? 'Startet neu...' : 'Neues Spiel starten'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWinnerBanner(Map<String, int> voteMap) {
    final winner = _rankings.where((r) => r.userId == _winnerId).firstOrNull;
    if (winner == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        const Text('🏆', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(winner.displayName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text('${voteMap[_winnerId] ?? 0} Votes', style: const TextStyle(color: Colors.white70)),
      ]),
    );
  }

  Widget _buildPlayerColumn(PlayerRanking ranking, Map<String, int> voteMap) {
    final sorted = List<RankingEntry>.from(ranking.entries)..sort((a, b) => a.position.compareTo(b.position));
    return Container(
      width: 170,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
            child: Column(children: [
              Text(ranking.displayName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              if (voteMap[ranking.userId] != null)
                Text('${voteMap[ranking.userId]} ❤️', style: const TextStyle(color: AppColors.accent, fontSize: 12)),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: sorted.map((entry) {
                final item = _itemsById[entry.itemId];
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(left: BorderSide(color: AppColors.rankColor(entry.position), width: 3)),
                  ),
                  child: Row(
                    children: [
                      CharacterImage(storedUrl: item?.imageUrl, characterName: item?.name ?? '', size: 28),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(entry.tier ?? '#${entry.position}', style: TextStyle(color: AppColors.rankColor(entry.position), fontWeight: FontWeight.bold, fontSize: 11)),
                          Text(item?.name ?? '?', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12), overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Wähle die beste Liste!', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ..._rankings.map((r) {
          final isMe = r.userId == widget.currentUser.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: OutlinedButton(
                onPressed: () => _vote(r.userId),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent, side: const BorderSide(color: AppColors.accent)),
                child: Text('${r.displayName}${isMe ? ' (Ich)' : ''} 👍'),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVoteResults(Map<String, int> voteMap) {
    final sorted = List<PlayerRanking>.from(_rankings)..sort((a, b) => (voteMap[b.userId] ?? 0).compareTo(voteMap[a.userId] ?? 0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ergebnisse', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...sorted.map((r) {
          final votes = voteMap[r.userId] ?? 0;
          final isWinner = r.userId == _winnerId;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isWinner ? Colors.amber.withOpacity(0.1) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isWinner ? Colors.amber : AppColors.border),
            ),
            child: Row(children: [
              if (isWinner) const Text('🏆 ', style: TextStyle(fontSize: 20)),
              Expanded(child: Text(r.displayName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
              Text('$votes Vote${votes != 1 ? 's' : ''}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
            ]),
          );
        }),
      ],
    );
  }
}
