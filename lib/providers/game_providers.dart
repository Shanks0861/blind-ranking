import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/firebase_service.dart';
import '../data/models/game_models.dart';

// ─────────────────────────────────────────────
// SERVICE PROVIDERS
// ─────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final lobbyServiceProvider = Provider<LobbyService>((ref) => LobbyService());

// ─────────────────────────────────────────────
// AUTH PROVIDERS
// ─────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserModelProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.read(authServiceProvider).getCurrentUserModel();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// ─────────────────────────────────────────────
// CURRENT LOBBY
// ─────────────────────────────────────────────
final currentLobbyIdProvider = StateProvider<String?>((ref) => null);

final lobbyStreamProvider =
    StreamProvider.family<LobbyModel?, String>((ref, lobbyId) {
  return ref.watch(lobbyServiceProvider).watchLobby(lobbyId);
});

final playersStreamProvider =
    StreamProvider.family<List<PlayerModel>, String>((ref, lobbyId) {
  return ref.watch(lobbyServiceProvider).watchPlayers(lobbyId);
});

final votesStreamProvider =
    StreamProvider.family<List<VoteModel>, String>((ref, lobbyId) {
  return ref.watch(lobbyServiceProvider).watchVotes(lobbyId);
});

// ─────────────────────────────────────────────
// GAME STATE PROVIDER (aggregated)
// ─────────────────────────────────────────────
final gameStateProvider =
    Provider.family<AsyncValue<GameState?>, String>((ref, lobbyId) {
  final lobby = ref.watch(lobbyStreamProvider(lobbyId));
  final players = ref.watch(playersStreamProvider(lobbyId));
  final votes = ref.watch(votesStreamProvider(lobbyId));
  final currentUser = ref.watch(currentUserModelProvider);

  if (lobby.isLoading || players.isLoading || votes.isLoading) {
    return const AsyncValue.loading();
  }

  if (lobby.hasError) return AsyncValue.error(lobby.error!, StackTrace.empty);

  final lobbyData = lobby.value;
  if (lobbyData == null) return const AsyncValue.data(null);

  final playersData = players.value ?? [];
  final votesData = votes.value ?? [];

  PlayerModel? currentPlayer;
  final currentUserData = currentUser.value;
  if (currentUserData != null) {
    try {
      currentPlayer =
          playersData.firstWhere((p) => p.userId == currentUserData.uid);
    } catch (_) {}
  }

  return AsyncValue.data(GameState(
    lobby: lobbyData,
    players: playersData,
    votes: votesData,
    currentPlayer: currentPlayer,
  ));
});

// ─────────────────────────────────────────────
// HUNTER STATE
// ─────────────────────────────────────────────
final hunterEliminationActiveProvider = StateProvider<bool>((ref) => false);
final hunterIdProvider = StateProvider<String?>((ref) => null);

// ─────────────────────────────────────────────
// VOTING COUNTDOWN
// ─────────────────────────────────────────────
final votingCountdownProvider =
    StreamProvider.family<int, int?>((ref, endsAt) async* {
  if (endsAt == null) {
    yield 0;
    return;
  }
  while (true) {
    final remaining = (endsAt - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
    if (remaining <= 0) {
      yield 0;
      return;
    }
    yield remaining;
    await Future.delayed(const Duration(seconds: 1));
  }
});
