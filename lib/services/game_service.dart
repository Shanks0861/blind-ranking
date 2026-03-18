import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_session.dart';
import '../models/lobby.dart';

class GameService {
  final SupabaseClient _client = Supabase.instance.client;

  // ── Session starten ────────────────────────────────────────────────────────

  Future<GameSession> startSession({
    required String lobbyId,
    required List<String> allItemIds,
    required ListSize listSize,
  }) async {
    final count = _itemCountForSize(listSize);
    final shuffled = List<String>.from(allItemIds)..shuffle(Random.secure());
    final queue = shuffled.take(count).toList();

    final data = await _client
        .from('game_sessions')
        .insert({
          'lobby_id': lobbyId,
          'item_queue': queue,
          'current_item_index': 0,
          'phase': GamePhase.ranking.name,
        })
        .select()
        .single();

    return GameSession.fromMap(data);
  }

  // ── Session abrufen ────────────────────────────────────────────────────────

  Future<GameSession?> fetchActiveSession(String lobbyId) async {
    final data = await _client
        .from('game_sessions')
        .select()
        .eq('lobby_id', lobbyId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return data != null ? GameSession.fromMap(data) : null;
  }

  // ── Ranking speichern ──────────────────────────────────────────────────────

  Future<PlayerRanking> saveRanking({
    required String sessionId,
    required String userId,
    required String displayName,
    required List<RankingEntry> entries,
  }) async {
    // Prüfen ob schon vorhanden → upsert
    final existing = await _client
        .from('player_rankings')
        .select()
        .eq('session_id', sessionId)
        .eq('user_id', userId)
        .maybeSingle();

    final payload = {
      'session_id': sessionId,
      'user_id': userId,
      'display_name': displayName,
      'entries': entries.map((e) => e.toMap()).toList(),
      'is_confirmed': true,
    };

    Map<String, dynamic> data;
    if (existing != null) {
      data = await _client
          .from('player_rankings')
          .update(payload)
          .eq('id', existing['id'])
          .select()
          .single();
    } else {
      data = await _client
          .from('player_rankings')
          .insert(payload)
          .select()
          .single();
    }

    return PlayerRanking.fromMap(data);
  }

  // ── Phase wechseln ─────────────────────────────────────────────────────────

  Future<void> advancePhase({
    required String sessionId,
    required GamePhase newPhase,
    int? newItemIndex,
  }) async {
    final updates = <String, dynamic>{'phase': newPhase.name};
    if (newItemIndex != null) updates['current_item_index'] = newItemIndex;
    await _client.from('game_sessions').update(updates).eq('id', sessionId);
  }

  Future<void> nextItem(String sessionId, int nextIndex) async {
    await _client.from('game_sessions').update({
      'current_item_index': nextIndex,
      'phase': GamePhase.ranking.name,
    }).eq('id', sessionId);
  }

  // ── Voting ─────────────────────────────────────────────────────────────────

  Future<void> submitVote({
    required String sessionId,
    required String voterId,
    required String votedForUserId,
  }) async {
    await _client.from('votes').upsert({
      'session_id': sessionId,
      'voter_id': voterId,
      'voted_for_user_id': votedForUserId,
    }, onConflict: 'session_id,voter_id');
  }

  Future<Map<String, int>> fetchVoteResults(String sessionId) async {
    final data = await _client
        .from('votes')
        .select()
        .eq('session_id', sessionId);

    final results = <String, int>{};
    for (final row in data as List) {
      final userId = row['voted_for_user_id'] as String;
      results[userId] = (results[userId] ?? 0) + 1;
    }
    return results;
  }

  // ── Rankings abrufen ───────────────────────────────────────────────────────

  Future<List<PlayerRanking>> fetchAllRankings(String sessionId) async {
    final data = await _client
        .from('player_rankings')
        .select()
        .eq('session_id', sessionId);
    return (data as List)
        .map((e) => PlayerRanking.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> allPlayersConfirmed({
    required String sessionId,
    required int playerCount,
  }) async {
    final data = await _client
        .from('player_rankings')
        .select('id')
        .eq('session_id', sessionId)
        .eq('is_confirmed', true);
    return (data as List).length >= playerCount;
  }

  // ── Realtime Subscriptions ─────────────────────────────────────────────────

  Stream<Map<String, dynamic>?> watchSession(String sessionId) {
    return _client
        .from('game_sessions')
        .stream(primaryKey: ['id'])
        .eq('id', sessionId)
        .map((rows) => rows.isNotEmpty ? rows.first : null);
  }

  Stream<List<Map<String, dynamic>>> watchRankings(String sessionId) {
    return _client
        .from('player_rankings')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId);
  }

  Stream<List<Map<String, dynamic>>> watchVotes(String sessionId) {
    return _client
        .from('votes')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId);
  }

  // ── Helper ─────────────────────────────────────────────────────────────────

  int _itemCountForSize(ListSize size) {
    switch (size) {
      case ListSize.top5:
        return 5;
      case ListSize.top10:
        return 10;
      case ListSize.tierList:
        return 15; // S A B C D F → flexible
    }
  }
}
