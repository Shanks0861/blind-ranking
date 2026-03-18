import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/game_session.dart';
import '../../models/lobby.dart';
import '../../models/category.dart';
import '../../services/game_service.dart';
import '../../services/category_service.dart';
import '../../utils/app_theme.dart';

class FinalScreen extends StatefulWidget {
  final GameSession session;
  final AppUser currentUser;
  final GameService gameService;
  final CategoryService categoryService;
  final bool isHost;

  const FinalScreen({
    super.key,
    required this.session,
    required this.currentUser,
    required this.gameService,
    required this.categoryService,
    required this.isHost,
  });

  @override
  State<FinalScreen> createState() => _FinalScreenState();
}

class _FinalScreenState extends State<FinalScreen> {
  List<PlayerRanking> _rankings = [];
  Map<String, GameItem> _itemsById = {};
  Map<String, int> _voteResults = {};
  bool _hasVoted = false;
  bool _votingOpen = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rankings =
        await widget.gameService.fetchAllRankings(widget.session.id);
    // Alle Item-IDs sammeln
    final allIds =
        rankings.expand((r) => r.entries.map((e) => e.itemId)).toSet().toList();
    final items = await widget.categoryService.fetchItemsByIds(allIds);

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
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: widget.gameService.watchVotes(widget.session.id),
              builder: (context, snapshot) {
                final votes = snapshot.data ?? [];
                final voteMap = <String, int>{};
                for (final v in votes) {
                  final uid = v['voted_for_user_id'] as String;
                  voteMap[uid] = (voteMap[uid] ?? 0) + 1;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gewinner Banner
                      if (_winnerId != null) _buildWinnerBanner(voteMap),
                      const SizedBox(height: 16),

                      // Alle Rankings
                      const Text('Alle Rankings',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 12),

                      // Horizontal scrollbar mit Player Columns
                      SizedBox(
                        height: 400,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _rankings.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _buildPlayerColumn(_rankings[i], voteMap),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Voting Bereich
                      if (!_votingOpen && widget.isHost)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _openVoting,
                            icon: const Icon(Icons.how_to_vote),
                            label: const Text('Voting starten'),
                          ),
                        ),
                      if (_votingOpen && !_hasVoted) _buildVotingButtons(),
                      if (_hasVoted) _buildVoteResults(voteMap),
                    ],
                  ),
                );
              },
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
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
        ),
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
                fontWeight: FontWeight.bold,
              )),
          Text('${voteMap[_winnerId] ?? 0} Votes',
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildPlayerColumn(PlayerRanking ranking, Map<String, int> voteMap) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
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
                      fontWeight: FontWeight.bold,
                    )),
                if (voteMap[ranking.userId] != null)
                  Text('${voteMap[ranking.userId]} ❤️',
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 12)),
              ],
            ),
          ),
          // Rankings
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: (List<RankingEntry>.from(ranking.entries)
                    ..sort((a, b) => a.position.compareTo(b.position)))
                  .map((entry) {
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
                      Text(
                        entry.tier ?? '${entry.position}',
                        style: TextStyle(
                          color: AppColors.rankColor(entry.position),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item?.name ?? '?',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
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
              fontSize: 16,
            )),
        const SizedBox(height: 12),
        ...others.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _vote(r.userId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                  child: Text('${r.displayName} 👍'),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildVoteResults(Map<String, int> voteMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ergebnisse',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )),
        const SizedBox(height: 12),
        ..._rankings.map((r) {
          final votes = voteMap[r.userId] ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: r.userId == _winnerId
                  ? Colors.amber.withOpacity(0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: r.userId == _winnerId ? Colors.amber : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                if (r.userId == _winnerId)
                  const Text('🏆 ', style: TextStyle(fontSize: 20)),
                Expanded(
                    child: Text(r.displayName,
                        style: const TextStyle(color: AppColors.textPrimary))),
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
}
