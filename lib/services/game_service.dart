import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lobby.dart';

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<GameSession> startSession({
    required String lobbyId,
    required List<String> allItemIds,
    required ListSize listSize,
  }) async {
    final count = _itemCountForSize(listSize);
    final unique = allItemIds.toSet().toList();
    unique.shuffle(Random.secure());
    final queue = unique.take(count).toList();

    final ref = _db.collection('game_sessions').doc();
    final session = GameSession(
      id: ref.id,
      lobbyId: lobbyId,
      itemQueue: queue,
      currentItemIndex: 0,
      phase: GamePhase.ranking,
    );
    await ref.set(session.toMap());
    return session;
  }

  Future<GameSession?> fetchActiveSession(String lobbyId) async {
    final snap = await _db
        .collection('game_sessions')
        .where('lobby_id', isEqualTo: lobbyId)
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return GameSession.fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  Future<PlayerRanking> saveRanking({
    required String sessionId,
    required String userId,
    required String displayName,
    required List<RankingEntry> entries,
  }) async {
    final existing = await _db
        .collection('player_rankings')
        .where('session_id', isEqualTo: sessionId)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    final payload = {
      'session_id': sessionId,
      'user_id': userId,
      'display_name': displayName,
      'entries': entries.map((e) => e.toMap()).toList(),
      'is_confirmed': true,
    };

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update(payload);
      return PlayerRanking.fromMap(existing.docs.first.id, {...existing.docs.first.data(), ...payload});
    } else {
      final ref = await _db.collection('player_rankings').add(payload);
      return PlayerRanking.fromMap(ref.id, payload);
    }
  }

  Future<void> advancePhase({
    required String sessionId,
    required GamePhase newPhase,
    int? newItemIndex,
  }) async {
    final updates = <String, dynamic>{'phase': newPhase.name};
    if (newItemIndex != null) updates['current_item_index'] = newItemIndex;
    await _db.collection('game_sessions').doc(sessionId).update(updates);
  }

  Future<void> nextItem(String sessionId, int nextIndex) async {
    await _db.collection('game_sessions').doc(sessionId).update({
      'current_item_index': nextIndex,
      'phase': GamePhase.ranking.name,
    });
  }

  Future<void> submitVote({
    required String sessionId,
    required String voterId,
    required String votedForUserId,
  }) async {
    final existing = await _db
        .collection('votes')
        .where('session_id', isEqualTo: sessionId)
        .where('voter_id', isEqualTo: voterId)
        .limit(1)
        .get();

    final payload = {
      'session_id': sessionId,
      'voter_id': voterId,
      'voted_for_user_id': votedForUserId,
    };

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update(payload);
    } else {
      await _db.collection('votes').add(payload);
    }
  }

  Future<Map<String, int>> fetchVoteResults(String sessionId) async {
    final snap = await _db
        .collection('votes')
        .where('session_id', isEqualTo: sessionId)
        .get();
    final results = <String, int>{};
    for (final doc in snap.docs) {
      final uid = doc.data()['voted_for_user_id'] as String;
      results[uid] = (results[uid] ?? 0) + 1;
    }
    return results;
  }

  Future<List<PlayerRanking>> fetchAllRankings(String sessionId) async {
    final snap = await _db
        .collection('player_rankings')
        .where('session_id', isEqualTo: sessionId)
        .get();
    return snap.docs
        .map((d) => PlayerRanking.fromMap(d.id, d.data()))
        .toList();
  }

  Stream<Map<String, dynamic>?> watchSession(String sessionId) {
    return _db
        .collection('game_sessions')
        .doc(sessionId)
        .snapshots()
        .map((snap) => snap.exists ? snap.data() : null);
  }

  Stream<List<Map<String, dynamic>>> watchRankings(String sessionId) {
    return _db
        .collection('player_rankings')
        .where('session_id', isEqualTo: sessionId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> watchVotes(String sessionId) {
    return _db
        .collection('votes')
        .where('session_id', isEqualTo: sessionId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  int _itemCountForSize(ListSize size) {
    switch (size) {
      case ListSize.top5: return 5;
      case ListSize.top10: return 10;
      case ListSize.tierList: return 15;
    }
  }
}
