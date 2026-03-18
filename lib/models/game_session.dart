import 'lobby.dart';

class GameSession {
  final String id;
  final String lobbyId;
  final List<String> itemQueue; // ordered item IDs
  final int currentItemIndex;
  final GamePhase phase;
  final List<PlayerRanking> rankings;
  final List<Vote> votes;

  const GameSession({
    required this.id,
    required this.lobbyId,
    required this.itemQueue,
    required this.currentItemIndex,
    required this.phase,
    this.rankings = const [],
    this.votes = const [],
  });

  String? get currentItemId =>
      currentItemIndex < itemQueue.length ? itemQueue[currentItemIndex] : null;

  bool get isLastItem => currentItemIndex >= itemQueue.length - 1;

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] as String,
      lobbyId: map['lobby_id'] as String,
      itemQueue: List<String>.from(map['item_queue'] as List),
      currentItemIndex: map['current_item_index'] as int? ?? 0,
      phase: GamePhase.values.byName(map['phase'] as String? ?? 'ranking'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lobby_id': lobbyId,
      'item_queue': itemQueue,
      'current_item_index': currentItemIndex,
      'phase': phase.name,
    };
  }

  GameSession copyWith({
    int? currentItemIndex,
    GamePhase? phase,
    List<PlayerRanking>? rankings,
    List<Vote>? votes,
  }) {
    return GameSession(
      id: id,
      lobbyId: lobbyId,
      itemQueue: itemQueue,
      currentItemIndex: currentItemIndex ?? this.currentItemIndex,
      phase: phase ?? this.phase,
      rankings: rankings ?? this.rankings,
      votes: votes ?? this.votes,
    );
  }
}

class RankingEntry {
  final String itemId;
  final int position; // 1-based, or tier index for tierlist
  final String? tier; // S, A, B, C, D, F

  const RankingEntry({
    required this.itemId,
    required this.position,
    this.tier,
  });

  factory RankingEntry.fromMap(Map<String, dynamic> map) {
    return RankingEntry(
      itemId: map['item_id'] as String,
      position: map['position'] as int,
      tier: map['tier'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'position': position,
      'tier': tier,
    };
  }
}

class PlayerRanking {
  final String id;
  final String sessionId;
  final String userId;
  final String displayName;
  final List<RankingEntry> entries;
  final bool isConfirmed;

  const PlayerRanking({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.displayName,
    required this.entries,
    required this.isConfirmed,
  });

  factory PlayerRanking.fromMap(Map<String, dynamic> map) {
    final entriesRaw = map['entries'] as List? ?? [];
    return PlayerRanking(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      userId: map['user_id'] as String,
      displayName: map['display_name'] as String,
      entries: entriesRaw
          .map((e) => RankingEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      isConfirmed: map['is_confirmed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'display_name': displayName,
      'entries': entries.map((e) => e.toMap()).toList(),
      'is_confirmed': isConfirmed,
    };
  }

  PlayerRanking copyWith({List<RankingEntry>? entries, bool? isConfirmed}) {
    return PlayerRanking(
      id: id,
      sessionId: sessionId,
      userId: userId,
      displayName: displayName,
      entries: entries ?? this.entries,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}

class Vote {
  final String id;
  final String sessionId;
  final String voterId;
  final String votedForUserId;

  const Vote({
    required this.id,
    required this.sessionId,
    required this.voterId,
    required this.votedForUserId,
  });

  factory Vote.fromMap(Map<String, dynamic> map) {
    return Vote(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      voterId: map['voter_id'] as String,
      votedForUserId: map['voted_for_user_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'voter_id': voterId,
      'voted_for_user_id': votedForUserId,
    };
  }
}
