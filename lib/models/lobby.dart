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
  final List<LobbyPlayer> players;
  final DateTime createdAt;

  const Lobby({
    required this.id,
    required this.code,
    required this.hostId,
    this.categoryId,
    this.subCategoryId,
    required this.listSize,
    required this.status,
    this.players = const [],
    required this.createdAt,
  });

  bool get isWaiting => status == LobbyStatus.waiting;
  bool get isPlaying => status == LobbyStatus.playing;

  factory Lobby.fromMap(Map<String, dynamic> map) {
    return Lobby(
      id: map['id'] as String,
      code: map['code'] as String,
      hostId: map['host_id'] as String,
      categoryId: map['category_id'] as String?,
      subCategoryId: map['sub_category_id'] as String?,
      listSize: ListSize.values.byName(map['list_size'] as String? ?? 'top10'),
      status: LobbyStatus.values.byName(map['status'] as String? ?? 'waiting'),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'host_id': hostId,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'list_size': listSize.name,
      'status': status.name,
    };
  }

  Lobby copyWith({
    String? categoryId,
    String? subCategoryId,
    ListSize? listSize,
    LobbyStatus? status,
    List<LobbyPlayer>? players,
  }) {
    return Lobby(
      id: id,
      code: code,
      hostId: hostId,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      listSize: listSize ?? this.listSize,
      status: status ?? this.status,
      players: players ?? this.players,
      createdAt: createdAt,
    );
  }
}

class LobbyPlayer {
  final String id;
  final String lobbyId;
  final String userId;
  final String displayName;
  final bool isHost;
  final bool isReady;

  const LobbyPlayer({
    required this.id,
    required this.lobbyId,
    required this.userId,
    required this.displayName,
    required this.isHost,
    required this.isReady,
  });

  factory LobbyPlayer.fromMap(Map<String, dynamic> map) {
    return LobbyPlayer(
      id: map['id'] as String,
      lobbyId: map['lobby_id'] as String,
      userId: map['user_id'] as String,
      displayName: map['display_name'] as String,
      isHost: map['is_host'] as bool? ?? false,
      isReady: map['is_ready'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lobby_id': lobbyId,
      'user_id': userId,
      'display_name': displayName,
      'is_host': isHost,
      'is_ready': isReady,
    };
  }
}
