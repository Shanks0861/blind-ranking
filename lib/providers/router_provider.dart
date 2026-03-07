import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/lobby/home_screen.dart';
import '../presentation/screens/lobby/create_lobby_screen.dart';
import '../presentation/screens/lobby/join_lobby_screen.dart';
import '../presentation/screens/lobby/lobby_screen.dart';
import '../presentation/screens/game/setup_screen.dart';
import '../presentation/screens/game/role_reveal_screen.dart';
import '../presentation/screens/game/game_screen.dart';
import '../presentation/screens/voting/voting_screen.dart';
import '../presentation/screens/game/game_over_screen.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/auth/guest_screen.dart';
import '../presentation/screens/game/single_device_screen.dart';
import '../presentation/screens/game/hunter_revenge_screen.dart';
import 'game_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.guest ||
          state.matchedLocation == AppRoutes.singleDevice;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.guest,
        builder: (_, __) => const GuestScreen(),
      ),
      GoRoute(
        path: '/hunter/:lobbyId',
        builder: (_, state) => HunterRevengeScreen(
          lobbyId: state.pathParameters['lobbyId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.singleDevice,
        builder: (_, __) => const SingleDeviceScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.createLobby,
        builder: (_, __) => const CreateLobbyScreen(),
      ),
      GoRoute(
        path: AppRoutes.joinLobby,
        builder: (_, __) => const JoinLobbyScreen(),
      ),
      GoRoute(
        path: AppRoutes.lobby,
        builder: (_, state) =>
            LobbyScreen(lobbyId: state.pathParameters['lobbyId']!),
      ),
      GoRoute(
        path: AppRoutes.setup,
        builder: (_, state) =>
            SetupScreen(lobbyId: state.pathParameters['lobbyId']!),
      ),
      GoRoute(
        path: AppRoutes.roleReveal,
        builder: (_, state) =>
            RoleRevealScreen(lobbyId: state.pathParameters['lobbyId']!),
      ),
      GoRoute(
        path: AppRoutes.game,
        builder: (_, state) =>
            GameScreen(lobbyId: state.pathParameters['lobbyId']!),
      ),
      GoRoute(
        path: AppRoutes.voting,
        builder: (_, state) =>
            VotingScreen(lobbyId: state.pathParameters['lobbyId']!),
      ),
      GoRoute(
        path: AppRoutes.gameOver,
        builder: (_, state) =>
            GameOverScreen(lobbyId: state.pathParameters['lobbyId']!),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});
