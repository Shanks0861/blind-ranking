import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lobby.dart';

class LobbyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Lobby> createLobby({required String hostId, required String hostDisplayName}) async {
    final code = _generateCode();
    final ref = _db.collection('lobbies').doc();
    final lobby = Lobby(id: ref.id, code: code, hostId: hostId, listSize: ListSize.top10, status: LobbyStatus.waiting, createdAt: DateTime.now());
    await ref.set(lobby.toMap());
    await _db.collection('lobby_players').add({'lobby_id': ref.id, 'user_id': hostId, 'display_name': hostDisplayName, 'is_host': true});
    return lobby;
  }

  Future<Lobby> joinLobby({required String code, required String userId, required String displayName}) async {
    final snap = await _db.collection('lobbies').where('code', isEqualTo: code.toUpperCase()).where('status', isEqualTo: 'waiting').limit(1).get();
    if (snap.docs.isEmpty) throw Exception('Lobby nicht gefunden oder bereits gestartet');
    final lobby = Lobby.fromMap(snap.docs.first.id, snap.docs.first.data());
    final existing = await _db.collection('lobby_players').where('lobby_id', isEqualTo: lobby.id).where('user_id', isEqualTo: userId).get();
    if (existing.docs.isEmpty) {
      await _db.collection('lobby_players').add({'lobby_id': lobby.id, 'user_id': userId, 'display_name': displayName, 'is_host': false});
    }
    return lobby;
  }

  Future<void> updateLobbySettings({required String lobbyId, String? categoryId, String? subCategoryId, bool clearSubCategory = false, ListSize? listSize}) async {
    final updates = <String, dynamic>{};
    if (categoryId != null) updates['category_id'] = categoryId;
    if (clearSubCategory || subCategoryId != null) updates['sub_category_id'] = subCategoryId;
    if (listSize != null) updates['list_size'] = listSize.name;
    if (updates.isNotEmpty) await _db.collection('lobbies').doc(lobbyId).update(updates);
  }

  Future<void> updateLobbyStatus({required String lobbyId, required LobbyStatus status}) async {
    await _db.collection('lobbies').doc(lobbyId).update({'status': status.name});
  }

  Stream<List<LobbyPlayer>> watchPlayers(String lobbyId) {
    return _db.collection('lobby_players').where('lobby_id', isEqualTo: lobbyId).snapshots().map((snap) => snap.docs.map((d) => LobbyPlayer.fromMap(d.id, d.data())).toList());
  }

  Stream<Map<String, dynamic>?> watchLobby(String lobbyId) {
    return _db.collection('lobbies').doc(lobbyId).snapshots().map((snap) => snap.exists ? snap.data() : null);
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
