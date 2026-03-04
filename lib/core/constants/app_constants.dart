class AppConstants {
  // Game phases
  static const String phaseSetup = 'setup';
  static const String phaseRoleReveal = 'role_reveal';
  static const String phaseDiscussion = 'discussion';
  static const String phaseVoting = 'voting';
  static const String phaseEvaluation = 'evaluation';
  static const String phaseGameOver = 'game_over';

  // Roles
  static const String roleMafia = 'mafia';
  static const String roleCitizen = 'citizen';
  static const String roleHunter = 'hunter';

  // Factions
  static const String factionMafia = 'mafia';
  static const String factionCitizen = 'citizen';

  // Firestore collections
  static const String colUsers = 'users';
  static const String colLobbies = 'lobbies';
  static const String colPlayers = 'players';
  static const String colVotes = 'votes';

  // Game defaults
  static const int defaultVotingDuration = 60; // seconds
  static const int minPlayers = 4;
  static const int maxPlayers = 20;

  // Abstention vote marker
  static const String abstain = 'abstain';
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String createLobby = '/lobby/create';
  static const String joinLobby = '/lobby/join';
  static const String lobby = '/lobby/:lobbyId';
  static const String setup = '/setup/:lobbyId';
  static const String roleReveal = '/role/:lobbyId';
  static const String game = '/game/:lobbyId';
  static const String voting = '/voting/:lobbyId';
  static const String gameOver = '/gameover/:lobbyId';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';
  static const String guest = '/guest';
}
