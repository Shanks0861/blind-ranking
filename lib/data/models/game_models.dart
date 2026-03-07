import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

// ─────────────────────────────────────────────
// USER MODEL
// ─────────────────────────────────────────────
class UserModel extends Equatable {
  final String uid;
  final String displayName;
  final String? profileImage;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    this.profileImage,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? 'Unknown',
      profileImage: data['profileImage'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'profileImage': profileImage,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? displayName,
    String? profileImage,
  }) =>
      UserModel(
        uid: uid,
        displayName: displayName ?? this.displayName,
        profileImage: profileImage ?? this.profileImage,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [uid, displayName, profileImage];
}

// ─────────────────────────────────────────────
// GAME SETTINGS MODEL
// ─────────────────────────────────────────────
class GameSettings extends Equatable {
  final int mafiaCount;
  final int citizenCount;
  final int hunterCount;
  final int votingDuration;
  final String gameMode; // 'single_device' | 'multi_device'

  const GameSettings({
    required this.mafiaCount,
    required this.citizenCount,
    this.hunterCount = 0,
    this.votingDuration = AppConstants.defaultVotingDuration,
    this.gameMode = 'multi_device',
  });

  int get totalPlayers => mafiaCount + citizenCount + hunterCount;

  factory GameSettings.fromMap(Map<String, dynamic> map) => GameSettings(
        mafiaCount: map['mafiaCount'] ?? 1,
        citizenCount: map['citizenCount'] ?? 3,
        hunterCount: map['hunterCount'] ?? 0,
        votingDuration:
            map['votingDuration'] ?? AppConstants.defaultVotingDuration,
        gameMode: map['gameMode'] ?? 'multi_device',
      );

  Map<String, dynamic> toMap() => {
        'mafiaCount': mafiaCount,
        'citizenCount': citizenCount,
        'hunterCount': hunterCount,
        'votingDuration': votingDuration,
        'gameMode': gameMode,
      };

  @override
  List<Object?> get props =>
      [mafiaCount, citizenCount, hunterCount, votingDuration, gameMode];
}

// ─────────────────────────────────────────────
// LOBBY MODEL
// ─────────────────────────────────────────────
class LobbyModel extends Equatable {
  final String lobbyId;
  final String hostId;
  final GameSettings settings;
  final String phase;
  final DateTime createdAt;
  final String? winnerId; // 'mafia' | 'citizen' | null
  final bool isOpen;
  final String? hunterTargetId;
  final int? votingEndsAt; // Unix timestamp ms

  const LobbyModel({
    required this.lobbyId,
    required this.hostId,
    required this.settings,
    required this.phase,
    required this.createdAt,
    this.winnerId,
    this.isOpen = true,
    this.hunterTargetId,
    this.votingEndsAt,
  });

  factory LobbyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LobbyModel(
      lobbyId: doc.id,
      hostId: data['hostId'] ?? '',
      settings: GameSettings.fromMap(data['settings'] ?? {}),
      phase: data['phase'] ?? AppConstants.phaseSetup,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      winnerId: data['winnerId'],
      isOpen: data['isOpen'] ?? true,
      hunterTargetId: data['hunterTargetId'] as String?,
      votingEndsAt: data['votingEndsAt'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'hostId': hostId,
        'settings': settings.toMap(),
        'phase': phase,
        'createdAt': Timestamp.fromDate(createdAt),
        'winnerId': winnerId,
        'isOpen': isOpen,
        'hunterTargetId': hunterTargetId,
        'votingEndsAt': votingEndsAt,
      };

  LobbyModel copyWith({
    String? phase,
    String? winnerId,
    bool? isOpen,
    String? hunterTargetId,
    int? votingEndsAt,
    GameSettings? settings,
  }) =>
      LobbyModel(
        lobbyId: lobbyId,
        hostId: hostId,
        settings: settings ?? this.settings,
        phase: phase ?? this.phase,
        createdAt: createdAt,
        winnerId: winnerId ?? this.winnerId,
        isOpen: isOpen ?? this.isOpen,
        hunterTargetId: hunterTargetId ?? this.hunterTargetId,
        votingEndsAt: votingEndsAt ?? this.votingEndsAt,
      );

  @override
  List<Object?> get props =>
      [lobbyId, hostId, phase, winnerId, isOpen, votingEndsAt];
}

// ─────────────────────────────────────────────
// PLAYER MODEL
// ─────────────────────────────────────────────
class PlayerModel extends Equatable {
  final String playerId; // doc id (= userId for multi-device)
  final String userId;
  final String displayName;
  final String? profileImage;
  final String role; // 'mafia' | 'citizen' | 'hunter'
  final String faction; // 'mafia' | 'citizen'
  final bool alive;
  final bool ready;
  final bool roleRevealed; // for single-device pass-around

  const PlayerModel({
    required this.playerId,
    required this.userId,
    required this.displayName,
    this.profileImage,
    this.role = '',
    this.faction = '',
    this.alive = true,
    this.ready = false,
    this.roleRevealed = false,
  });

  factory PlayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlayerModel(
      playerId: doc.id,
      userId: data['userId'] ?? doc.id,
      displayName: data['displayName'] ?? 'Unknown',
      profileImage: data['profileImage'],
      role: data['role'] ?? '',
      faction: data['faction'] ?? '',
      alive: data['alive'] ?? true,
      ready: data['ready'] ?? false,
      roleRevealed: data['roleRevealed'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'displayName': displayName,
        'profileImage': profileImage,
        'role': role,
        'faction': faction,
        'alive': alive,
        'ready': ready,
        'roleRevealed': roleRevealed,
      };

  PlayerModel copyWith({
    String? role,
    String? faction,
    bool? alive,
    bool? ready,
    bool? roleRevealed,
  }) =>
      PlayerModel(
        playerId: playerId,
        userId: userId,
        displayName: displayName,
        profileImage: profileImage,
        role: role ?? this.role,
        faction: faction ?? this.faction,
        alive: alive ?? this.alive,
        ready: ready ?? this.ready,
        roleRevealed: roleRevealed ?? this.roleRevealed,
      );

  String get roleDisplayName {
    switch (role) {
      case AppConstants.roleMafia:
        return 'Mafia';
      case AppConstants.roleCitizen:
        return 'Bürger';
      case AppConstants.roleHunter:
        return 'Jäger';
      default:
        return 'Unbekannt';
    }
  }

  String get roleEmoji {
    switch (role) {
      case AppConstants.roleMafia:
        return '🔪';
      case AppConstants.roleCitizen:
        return '👨‍🌾';
      case AppConstants.roleHunter:
        return '🏹';
      default:
        return '❓';
    }
  }

  @override
  List<Object?> get props =>
      [playerId, userId, role, faction, alive, ready, roleRevealed];
}

// ─────────────────────────────────────────────
// VOTE MODEL
// ─────────────────────────────────────────────
class VoteModel extends Equatable {
  final String voterId;
  final String targetId; // playerId or 'abstain'
  final DateTime timestamp;

  const VoteModel({
    required this.voterId,
    required this.targetId,
    required this.timestamp,
  });

  factory VoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VoteModel(
      voterId: doc.id,
      targetId: data['targetId'] ?? AppConstants.abstain,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'targetId': targetId,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  bool get isAbstain => targetId == AppConstants.abstain;

  @override
  List<Object?> get props => [voterId, targetId];
}

// ─────────────────────────────────────────────
// GAME STATE (local aggregation)
// ─────────────────────────────────────────────
class GameState extends Equatable {
  final LobbyModel lobby;
  final List<PlayerModel> players;
  final List<VoteModel> votes;
  final PlayerModel? currentPlayer; // the local user's player

  const GameState({
    required this.lobby,
    required this.players,
    required this.votes,
    this.currentPlayer,
  });

  List<PlayerModel> get alivePlayers => players.where((p) => p.alive).toList();
  List<PlayerModel> get deadPlayers => players.where((p) => !p.alive).toList();

  List<PlayerModel> get aliveMafia => alivePlayers
      .where((p) => p.faction == AppConstants.factionMafia)
      .toList();

  List<PlayerModel> get aliveCitizens => alivePlayers
      .where((p) => p.faction == AppConstants.factionCitizen)
      .toList();

  bool get mafiaWins => aliveMafia.length >= aliveCitizens.length;
  bool get citizensWin => aliveMafia.isEmpty;

  Map<String, int> get voteCounts {
    final counts = <String, int>{};
    for (final vote in votes) {
      if (!vote.isAbstain) {
        counts[vote.targetId] = (counts[vote.targetId] ?? 0) + 1;
      }
    }
    return counts;
  }

  String? get eliminatedPlayerId {
    final counts = voteCounts;
    if (counts.isEmpty) return null;
    final maxVotes = counts.values.reduce((a, b) => a > b ? a : b);
    final topPlayers =
        counts.entries.where((e) => e.value == maxVotes).toList();
    if (topPlayers.length > 1) return null; // tie → nobody eliminated
    return topPlayers.first.key;
  }

  @override
  List<Object?> get props => [lobby, players, votes, currentPlayer];
}
