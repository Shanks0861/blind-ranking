import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/game_session.dart';
import '../../models/lobby.dart';
import '../../models/category.dart';
import '../../services/game_service.dart';
import '../../services/category_service.dart';
import '../../utils/app_theme.dart';
import '../game/game_screen.dart';

class FinalScreen extends StatefulWidget {
  final GameSession session;
  final AppUser currentUser;
  final GameService gameService;
  final CategoryService categoryService;
  final bool isHost;
  final Map<int, GameItem> myPlacedItems;

  const FinalScreen({
    super.key,
    required this.session,
    required this.currentUser,
    required this.gameService,
    required this.categoryService,
    required this.isHost,
    required this.myPlacedItems,
  });

  @override
  State<FinalScreen> createState() => _FinalScreenState();
}

class _FinalScreenState extends State<FinalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<PlayerRanking> _rankings = [];
  Map<String, GameItem> _itemsById = {};
  Map<String, int> _voteResults = {};
  bool _hasVoted = false;
  bool _votingOpen = false;
  bool _loading = true;

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
    final rankings =
        await widget.gameService.fetchAllRankings(widget.session.id);
    final allIds =
        rankings.expand((r) => r.entries.map((e) => e.itemId)).toSet().toList();
    final items = await widget.categoryService.fetchItemsByIds(allIds);
    // Auch eigene Placed-Items einfügen falls noch nicht drin
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
    await widget.gameService.advancePhase(
      sessionId: widget.session.id,
      newPhase: GamePhase.voting,
    );
    setState(() => _votingOpen = true);
  }

  Future<void> _vote(String votedForUserId) async {
    if (_hasVoted) return;
    await widget.gameService.submitVote(
      sessionId: widget.session.id,
      voterId: widget.currentUser.id,
      votedForUserId: votedForUserId,
    );
    final results =
        await widget.gameService.fetchVoteResults(widget.session.id);
    setState(() {
      _voteResults = results;
      _hasVoted = true;
    });
  }

  String? get _winnerId {
    if (_voteResults.isEmpty) return null;
    return _voteResults.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text('🏁 Finale',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Meine Liste'),
            Tab(text: 'Alle Rankings'),
          ],
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
                final votes = voteSnap.data ?? [];
                final voteMap = <String, int>{};
                for (final v in votes) {
                  final uid = v['voted_for_user_id'] as String;
                  voteMap[uid] = (voteMap[uid] ?? 0) + 1;
                }

                // Voting automatisch öffnen wenn Host es gestartet hat
                if (voteSnap.hasData && !_votingOpen) {
                  final sessionVotingOpen =
                      widget.session.phase == GamePhase.voting;
                  if (sessionVotingOpen) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _votingOpen = true);
                    });
                  }
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
                    }

                    return TabBarView(
                      controller: _tabCtrl,
                      children: [
                        _buildMyList(),
                        _buildAllRankings(voteMap),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  // ── Tab 1: Meine Liste ────────────────────────────────────────────────────

  Widget _buildMyList() {
    final sorted = widget.myPlacedItems.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sorted.isEmpty) {
      return const Center(
        child: Text('Keine platzierten Items',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final pos = sorted[i].key;
        final item = sorted[i].value;
        final color = AppColors.rankColor(pos);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 70,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(13)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${pos}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              const SizedBox(width: 14),
              _netImage(item.imageUrl, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Text(item.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 2: Alle Rankings + Voting ─────────────────────────────────────────

  Widget _buildAllRankings(Map<String, int> voteMap) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gewinner Banner
          if (_winnerId != null) ...[
            _buildWinnerBanner(voteMap),
            const SizedBox(height: 16),
          ],

          // Player Columns horizontal
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

          // Voting
          if (widget.isHost && !_votingOpen)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _openVoting,
                icon: const Icon(Icons.how_to_vote),
                label: const Text('Voting starten'),
              ),
            ),
          if (_votingOpen &&
              !_hasVoted &&
              widget.currentUser.id != '') // eigene Stimme abgeben
            _buildVotingButtons(),
          if (_hasVoted) _buildVoteResults(voteMap),
          if (_votingOpen && !_hasVoted) const SizedBox(height: 8),
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(winner.displayName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          Text('${voteMap[_winnerId] ?? 0} Votes',
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildPlayerColumn(PlayerRanking ranking, Map<String, int> voteMap) {
    final sorted = List<RankingEntry>.from(ranking.entries)
      ..sort((a, b) => a.position.compareTo(b.position));

    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Column(
              children: [
                Text(ranking.displayName,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
                if (voteMap[ranking.userId] != null)
                  Text('${voteMap[ranking.userId]} ❤️',
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: sorted.map((entry) {
                final item = _itemsById[entry.itemId];
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: AppColors.rankColor(entry.position),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _netImage(item?.imageUrl, size: 28),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.tier ?? '#${entry.position}',
                              style: TextStyle(
                                color: AppColors.rankColor(entry.position),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              item?.name ?? '?',
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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
    final others =
        _rankings.where((r) => r.userId != widget.currentUser.id).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Wähle die beste Liste!',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 12),
        ...others.map((r) {
          final votes = _voteResults[r.userId] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => _vote(r.userId),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                ),
                child: Text('${r.displayName} 👍'),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVoteResults(Map<String, int> voteMap) {
    final sorted = List<PlayerRanking>.from(_rankings)
      ..sort(
          (a, b) => (voteMap[b.userId] ?? 0).compareTo(voteMap[a.userId] ?? 0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ergebnisse',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 12),
        ...sorted.map((r) {
          final votes = voteMap[r.userId] ?? 0;
          final isWinner = r.userId == _winnerId;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isWinner ? Colors.amber.withOpacity(0.1) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isWinner ? Colors.amber : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                if (isWinner) const Text('🏆 ', style: TextStyle(fontSize: 20)),
                Expanded(
                  child: Text(r.displayName,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                ),
                Text('$votes Vote${votes != 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: AppColors.accent, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _netImage(String? url, {required double size}) {
    if (url == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.image_outlined,
            color: AppColors.textSecondary, size: size * 0.5),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: AppColors.surfaceVariant,
          child: Icon(Icons.broken_image,
              color: AppColors.textSecondary, size: size * 0.5),
        ),
      ),
    );
  }
}
