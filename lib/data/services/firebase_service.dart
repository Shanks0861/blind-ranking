import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_models.dart';
import '../../core/constants/app_constants.dart';

// ─────────────────────────────────────────────
// AUTH SERVICE
// ─────────────────────────────────────────────
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) return null;
    return _getOrCreateUser(credential.user!);
  }

  Future<UserModel?> registerWithEmail(
      String email, String password, String displayName) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) return null;
    await credential.user!.updateDisplayName(displayName);
    return _createUserDoc(credential.user!, displayName);
  }

  Future<UserModel?> signInAnonymously(String displayName) async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user == null) return null;
      await user.updateDisplayName(displayName);
      return await _getOrCreateUser(user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel> _getOrCreateUser(User user) async {
    final doc = await _db.collection(AppConstants.colUsers).doc(user.uid).get();
    if (doc.exists) return UserModel.fromFirestore(doc);
    return _createUserDoc(
        user, user.displayName ?? user.email?.split('@').first ?? 'Player');
  }

  Future<UserModel> _createUserDoc(User user, String displayName) async {
    final userModel = UserModel(
      uid: user.uid,
      displayName: displayName,
      profileImage: user.photoURL,
      createdAt: DateTime.now(),
    );
    await _db
        .collection(AppConstants.colUsers)
        .doc(user.uid)
        .set(userModel.toFirestore());
    return userModel;
  }

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection(AppConstants.colUsers).doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}

// ─────────────────────────────────────────────
// LOBBY SERVICE
// ─────────────────────────────────────────────
class LobbyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _generateLobbyCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<LobbyModel> createLobby({
    required String hostId,
    required GameSettings settings,
  }) async {
    final lobbyId = _generateLobbyCode();
    final lobby = LobbyModel(
      lobbyId: lobbyId,
      hostId: hostId,
      settings: settings,
      phase: AppConstants.phaseSetup,
      createdAt: DateTime.now(),
    );
    await _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .set(lobby.toFirestore());
    return lobby;
  }

  Future<LobbyModel?> getLobbyByCode(String code) async {
    try {
      final doc = await _db
          .collection(AppConstants.colLobbies)
          .doc(code.toUpperCase())
          .get();
      if (!doc.exists) return null;
      final lobby = LobbyModel.fromFirestore(doc);
      if (lobby.phase != AppConstants.phaseSetup) return null;
      return lobby;
    } catch (e) {
      return null;
    }
  }

  Future<LobbyModel?> getLobby(String lobbyId) async {
    final doc = await _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId.toUpperCase())
        .get();
    if (!doc.exists) return null;
    return LobbyModel.fromFirestore(doc);
  }

  Stream<LobbyModel?> watchLobby(String lobbyId) {
    return _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId.toUpperCase())
        .snapshots()
        .map((doc) => doc.exists ? LobbyModel.fromFirestore(doc) : null);
  }

  Stream<List<PlayerModel>> watchPlayers(String lobbyId) {
    return _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .collection(AppConstants.colPlayers)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PlayerModel.fromFirestore(d)).toList());
  }

  Stream<List<VoteModel>> watchVotes(String lobbyId) {
    return _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .collection(AppConstants.colVotes)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => VoteModel.fromFirestore(d)).toList());
  }

  Future<void> joinLobby({
    required String lobbyId,
    required UserModel user,
  }) async {
    final playerRef = _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .collection(AppConstants.colPlayers)
        .doc(user.uid);

    await playerRef.set(PlayerModel(
      playerId: user.uid,
      userId: user.uid,
      displayName: user.displayName,
      profileImage: user.profileImage,
    ).toFirestore());
  }

  Future<void> leaveLobby(String lobbyId, String userId) async {
    await _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .collection(AppConstants.colPlayers)
        .doc(userId)
        .delete();
  }

  Future<void> updateSettings(String lobbyId, GameSettings settings) async {
    await _db.collection(AppConstants.colLobbies).doc(lobbyId).update({
      'settings': settings.toMap(),
    });
  }

  Future<void> distributeRoles(String lobbyId) async {
    final playersSnap = await _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .collection(AppConstants.colPlayers)
        .get();

    final lobbyDoc =
        await _db.collection(AppConstants.colLobbies).doc(lobbyId).get();
    final lobby = LobbyModel.fromFirestore(lobbyDoc);
    final settings = lobby.settings;

    final roles = <Map<String, String>>[];
    for (int i = 0; i < settings.mafiaCount; i++) {
      roles.add({
        'role': AppConstants.roleMafia,
        'faction': AppConstants.factionMafia
      });
    }
    for (int i = 0; i < settings.hunterCount; i++) {
      roles.add({
        'role': AppConstants.roleHunter,
        'faction': AppConstants.factionCitizen
      });
    }
    for (int i = 0; i < settings.citizenCount; i++) {
      roles.add({
        'role': AppConstants.roleCitizen,
        'faction': AppConstants.factionCitizen
      });
    }

    roles.shuffle(Random.secure());

    final batch = _db.batch();
    final playerDocs = playersSnap.docs;
    for (int i = 0; i < playerDocs.length && i < roles.length; i++) {
      batch.update(playerDocs[i].reference, roles[i]);
    }

    batch.update(_db.collection(AppConstants.colLobbies).doc(lobbyId),
        {'phase': AppConstants.phaseRoleReveal, 'isOpen': false});

    await batch.commit();
  }

  Future<void> startDiscussion(String lobbyId) async {
    await _db.collection(AppConstants.colLobbies).doc(lobbyId).update({
      'phase': AppConstants.phaseDiscussion,
    });
  }

  Future<void> startVoting(String lobbyId, int durationSeconds) async {
    final endsAt =
        DateTime.now().millisecondsSinceEpoch + (durationSeconds * 1000);
    await _db.collection(AppConstants.colLobbies).doc(lobbyId).update({
      'phase': AppConstants.phaseVoting,
      'votingEndsAt': endsAt,
    });
  }

  Future<void> castVote({
    required String lobbyId,
    required String voterId,
    required String targetId,
  }) async {
    await _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .collection(AppConstants.colVotes)
        .doc(voterId)
        .set(VoteModel(
          voterId: voterId,
          targetId: targetId,
          timestamp: DateTime.now(),
        ).toFirestore());
  }

  Future<void> evaluateVotes(String lobbyId) async {
    final votesSnap = await _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .collection(AppConstants.colVotes)
        .get();

    final votes =
        votesSnap.docs.map((d) => VoteModel.fromFirestore(d)).toList();

    final counts = <String, int>{};
    for (final vote in votes) {
      if (!vote.isAbstain) {
        counts[vote.targetId] = (counts[vote.targetId] ?? 0) + 1;
      }
    }

    final batch = _db.batch();
    final lobbyRef = _db.collection(AppConstants.colLobbies).doc(lobbyId);

    if (counts.isNotEmpty) {
      final maxVotes = counts.values.reduce((a, b) => a > b ? a : b);
      final topPlayers =
          counts.entries.where((e) => e.value == maxVotes).toList();

      if (topPlayers.length == 1) {
        final eliminatedId = topPlayers.first.key;
        final playerRef = _db
            .collection(AppConstants.colLobbies)
            .doc(lobbyId)
            .collection(AppConstants.colPlayers)
            .doc(eliminatedId);
        batch.update(playerRef, {'alive': false});
      }
    }

    for (final doc in votesSnap.docs) {
      batch.delete(doc.reference);
    }

    batch.update(lobbyRef, {'phase': AppConstants.phaseEvaluation});
    await batch.commit();
  }

  Future<void> checkWinCondition(String lobbyId) async {
    final playersSnap = await _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .collection(AppConstants.colPlayers)
        .get();

    final players =
        playersSnap.docs.map((d) => PlayerModel.fromFirestore(d)).toList();
    final alive = players.where((p) => p.alive).toList();
    final aliveMafia =
        alive.where((p) => p.faction == AppConstants.factionMafia).toList();
    final aliveCitizens =
        alive.where((p) => p.faction == AppConstants.factionCitizen).toList();

    final lobbyRef = _db.collection(AppConstants.colLobbies).doc(lobbyId);

    if (aliveMafia.isEmpty) {
      await lobbyRef.update({
        'phase': AppConstants.phaseGameOver,
        'winnerId': AppConstants.factionCitizen,
      });
    } else if (aliveMafia.length >= aliveCitizens.length) {
      await lobbyRef.update({
        'phase': AppConstants.phaseGameOver,
        'winnerId': AppConstants.factionMafia,
      });
    } else {
      await lobbyRef.update({'phase': AppConstants.phaseDiscussion});
    }
  }

  Future<void> resetGame(String lobbyId) async {
    final votesSnap = await _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .collection(AppConstants.colVotes)
        .get();

    final batch = _db.batch();
    for (final doc in votesSnap.docs) {
      batch.delete(doc.reference);
    }

    final playersSnap = await _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .collection(AppConstants.colPlayers)
        .get();
    for (final doc in playersSnap.docs) {
      batch.update(doc.reference, {
        'alive': true,
        'role': '',
        'faction': '',
        'roleRevealed': false,
      });
    }

    batch.update(_db.collection(AppConstants.colLobbies).doc(lobbyId), {
      'phase': AppConstants.phaseSetup,
      'winnerId': null,
      'isOpen': true,
      'votingEndsAt': null,
    });

    await batch.commit();
  }

  Future<void> removePlayer(String lobbyId, String playerId) async {
    await _db
        .collection(AppConstants.colLobbies)
        .doc(lobbyId)
        .collection(AppConstants.colPlayers)
        .doc(playerId)
        .delete();
  }
}
