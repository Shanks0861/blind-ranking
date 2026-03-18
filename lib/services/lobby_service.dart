import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lobby.dart';

class LobbyService {
  final SupabaseClient _client = Supabase.instance.client;

  // ── Lobby erstellen ────────────────────────────────────────────────────────

  Future<Lobby> createLobby({
    required String hostId,
    required String hostDisplayName,
  }) async {
    final code = _generateCode();

    final lobbyData = await _client
        .from('lobbies')
        .insert({
          'code': code,
          'host_id': hostId,
          'list_size': ListSize.top10.name,
          'status': LobbyStatus.waiting.name,
        })
        .select()
        .single();

    final lobby = Lobby.fromMap(lobbyData);

    // Host als Spieler hinzufügen
    await _addPlayer(
      lobbyId: lobby.id,
      userId: hostId,
      displayName: hostDisplayName,
      isHost: true,
    );

    return lobby;
  }

  // ── Lobby beitreten ────────────────────────────────────────────────────────

  Future<Lobby> joinLobby({
    required String code,
    required String userId,
    required String displayName,
  }) async {
    final lobbyData = await _client
        .from('lobbies')
        .select()
        .eq('code', code.toUpperCase())
        .eq('status', LobbyStatus.waiting.name)
        .maybeSingle();

    if (lobbyData == null) {
      throw Exception('Lobby nicht gefunden oder bereits gestartet');
    }

    final lobby = Lobby.fromMap(lobbyData);

    // Prüfen ob schon in der Lobby
    final existing = await _client
        .from('lobby_players')
        .select()
        .eq('lobby_id', lobby.id)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing == null) {
      await _addPlayer(
        lobbyId: lobby.id,
        userId: userId,
        displayName: displayName,
        isHost: false,
      );
    }

    return lobby;
  }

  // ── Lobby Einstellungen updaten ────────────────────────────────────────────

  Future<void> updateLobbySettings({
    required String lobbyId,
    String? categoryId,
    String? subCategoryId,
    bool clearSubCategory = false,
    ListSize? listSize,
  }) async {
    final updates = <String, dynamic>{};
    if (categoryId != null) updates['category_id'] = categoryId;
    // clearSubCategory=true setzt explizit auf null ("Alle" gewählt)
    if (clearSubCategory || subCategoryId != null) {
      updates['sub_category_id'] = subCategoryId;
    }
    if (listSize != null) updates['list_size'] = listSize.name;

    if (updates.isNotEmpty) {
      await _client.from('lobbies').update(updates).eq('id', lobbyId);
    }
  }

  Future<void> updateLobbyStatus({
    required String lobbyId,
    required LobbyStatus status,
  }) async {
    await _client
        .from('lobbies')
        .update({'status': status.name}).eq('id', lobbyId);
  }

  // ── Lobby verlassen ────────────────────────────────────────────────────────

  Future<void> leaveLobby({
    required String lobbyId,
    required String userId,
  }) async {
    await _client
        .from('lobby_players')
        .delete()
        .eq('lobby_id', lobbyId)
        .eq('user_id', userId);
  }

  // ── Realtime Subscription ──────────────────────────────────────────────────

  Stream<List<LobbyPlayer>> watchPlayers(String lobbyId) {
    return _client
        .from('lobby_players')
        .stream(primaryKey: ['id'])
        .eq('lobby_id', lobbyId)
        .map(
          (rows) => rows.map((r) => LobbyPlayer.fromMap(r)).toList(),
        );
  }

  Stream<Map<String, dynamic>?> watchLobby(String lobbyId) {
    return _client
        .from('lobbies')
        .stream(primaryKey: ['id'])
        .eq('id', lobbyId)
        .map((rows) => rows.isNotEmpty ? rows.first : null);
  }

  // ── Spieler Daten abrufen ──────────────────────────────────────────────────

  Future<List<LobbyPlayer>> fetchPlayers(String lobbyId) async {
    final data =
        await _client.from('lobby_players').select().eq('lobby_id', lobbyId);
    return (data as List)
        .map((e) => LobbyPlayer.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  Future<void> _addPlayer({
    required String lobbyId,
    required String userId,
    required String displayName,
    required bool isHost,
  }) async {
    await _client.from('lobby_players').insert({
      'lobby_id': lobbyId,
      'user_id': userId,
      'display_name': displayName,
      'is_host': isHost,
      'is_ready': false,
    });
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
