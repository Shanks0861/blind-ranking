enum ListSize { top5, top10, tierList }
enum LobbyStatus { waiting, playing, finished }
enum GamePhase { ranking, reveal, finalPhase, voting, done }

class Lobby {
  final String id;
  final String code;
  final String hostId;
  final String? categoryId;
  final String? subCategoryId;
  final ListSize listSize;
  final LobbyStatus status;
  final DateTime createdAt;

  const Lobby({required this.id, required this.code, required this.hostId, this.categoryId, this.subCategoryId, required this.listSize, required this.status, required this.createdAt});

  factory Lobby.fromMap(String id, Map<String, dynamic> map) {
    return Lobby(id: id, code: map['code'] as String, hostId: map['host_id'] as String, categoryId: map['category_id'] as String?, subCategoryId: map['sub_category_id'] as String?, listSize: ListSize.values.byName(map['list_size'] as String? ?? 'top10'), status: LobbyStatus.values.byName(map['status'] as String? ?? 'waiting'), createdAt: DateTime.parse(map['created_at'] as String));
  }

  Map<String, dynamic> toMap() => {'code': code, 'host_id': hostId, 'category_id': categoryId, 'sub_category_id': subCategoryId, 'list_size': listSize.name, 'status': status.name, 'created_at': createdAt.toIso8601String()};

  Lobby copyWith({String? categoryId, String? subCategoryId, ListSize? listSize, LobbyStatus? status}) {
    return Lobby(id: id, code: code, hostId: hostId, categoryId: categoryId ?? this.categoryId, subCategoryId: subCategoryId ?? this.subCategoryId, listSize: listSize ?? this.listSize, status: status ?? this.status, createdAt: createdAt);
  }
}

class LobbyPlayer {
  final String id;
  final String lobbyId;
  final String userId;
  final String displayName;
  final bool isHost;

  const LobbyPlayer({required this.id, required this.lobbyId, required this.userId, required this.displayName, required this.isHost});

  factory LobbyPlayer.fromMap(String id, Map<String, dynamic> map) {
    return LobbyPlayer(id: id, lobbyId: map['lobby_id'] as String, userId: map['user_id'] as String, displayName: map['display_name'] as String, isHost: map['is_host'] as bool? ?? false);
  }

  Map<String, dynamic> toMap() => {'lobby_id': lobbyId, 'user_id': userId, 'display_name': displayName, 'is_host': isHost};
}

class GameSession {
  final String id;
  final String lobbyId;
  final List<String> itemQueue;
  final int currentItemIndex;
  final GamePhase phase;

  const GameSession({required this.id, required this.lobbyId, required this.itemQueue, required this.currentItemIndex, required this.phase});

  String? get currentItemId => currentItemIndex < itemQueue.length ? itemQueue[currentItemIndex] : null;
  bool get isLastItem => currentItemIndex >= itemQueue.length - 1;

  factory GameSession.fromMap(String id, Map<String, dynamic> map) {
    return GameSession(id: id, lobbyId: map['lobby_id'] as String, itemQueue: List<String>.from(map['item_queue'] as List), currentItemIndex: map['current_item_index'] as int? ?? 0, phase: GamePhase.values.byName(map['phase'] as String? ?? 'ranking'));
  }

  Map<String, dynamic> toMap() => {'lobby_id': lobbyId, 'item_queue': itemQueue, 'current_item_index': currentItemIndex, 'phase': phase.name, 'created_at': DateTime.now().toIso8601String()};
}

class RankingEntry {
  final String itemId;
  final int position;
  final String? tier;

  const RankingEntry({required this.itemId, required this.position, this.tier});

  factory RankingEntry.fromMap(Map<String, dynamic> map) => RankingEntry(itemId: map['item_id'] as String, position: map['position'] as int, tier: map['tier'] as String?);
  Map<String, dynamic> toMap() => {'item_id': itemId, 'position': position, 'tier': tier};
}

class PlayerRanking {
  final String id;
  final String sessionId;
  final String userId;
  final String displayName;
  final List<RankingEntry> entries;
  final bool isConfirmed;

  const PlayerRanking({required this.id, required this.sessionId, required this.userId, required this.displayName, required this.entries, required this.isConfirmed});

  factory PlayerRanking.fromMap(String id, Map<String, dynamic> map) {
    final entriesRaw = map['entries'] as List? ?? [];
    return PlayerRanking(id: id, sessionId: map['session_id'] as String, userId: map['user_id'] as String, displayName: map['display_name'] as String, entries: entriesRaw.map((e) => RankingEntry.fromMap(e as Map<String, dynamic>)).toList(), isConfirmed: map['is_confirmed'] as bool? ?? false);
  }

  Map<String, dynamic> toMap() => {'session_id': sessionId, 'user_id': userId, 'display_name': displayName, 'entries': entries.map((e) => e.toMap()).toList(), 'is_confirmed': isConfirmed};
}

class Vote {
  final String id;
  final String sessionId;
  final String voterId;
  final String votedForUserId;

  const Vote({required this.id, required this.sessionId, required this.voterId, required this.votedForUserId});

  factory Vote.fromMap(String id, Map<String, dynamic> map) => Vote(id: id, sessionId: map['session_id'] as String, voterId: map['voter_id'] as String, votedForUserId: map['voted_for_user_id'] as String);
  Map<String, dynamic> toMap() => {'session_id': sessionId, 'voter_id': voterId, 'voted_for_user_id': votedForUserId};
}
