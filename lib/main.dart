import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/app_user.dart';
import 'services/auth_service.dart';
import 'services/lobby_service.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/lobby/home_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const BlindRankingApp());
}

class BlindRankingApp extends StatelessWidget {
  const BlindRankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blind Ranking',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const RootNavigator(),
    );
  }
}

class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  final _authService = AuthService();
  final _lobbyService = LobbyService();
  AppUser? _user;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _authService.authStateChanges.listen(_onAuthChange);
  }

  Future<void> _checkAuth() async {
    final user = await _authService.fetchCurrentUser();
    setState(() {
      _user = user;
      _checking = false;
    });
  }

  void _onAuthChange(AuthState state) async {
    if (state.event == AuthChangeEvent.signedIn) {
      final user = await _authService.fetchCurrentUser();
      setState(() => _user = user);
    } else if (state.event == AuthChangeEvent.signedOut) {
      setState(() => _user = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return AuthScreen(
        authService: _authService,
        onAuthenticated: _checkAuth,
      );
    }

    return HomeScreen(
      user: _user!,
      lobbyService: _lobbyService,
      authService: _authService,
    );
  }
}

class AppConstants {
  static const String supabaseUrl = 'https://dadfpdkvivsvxmdrwjqc.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_0TuuuvLoHqV0o087xFPhYg_dm2pCPBS';
}
