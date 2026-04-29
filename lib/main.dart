import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/app_user.dart';
import 'services/auth_service.dart';
import 'services/lobby_service.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/lobby/home_screen.dart';
import 'utils/app_theme.dart';

const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
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
    // Timeout damit die App nie ewig lädt
    try {
      final user = await _authService
          .fetchCurrentUser()
          .timeout(const Duration(seconds: 5));
      if (mounted)
        setState(() {
          _user = user;
          _checking = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _user = null;
          _checking = false;
        });
    }
  }

  void _onAuthChange(AuthState state) async {
    if (state.event == AuthChangeEvent.signedIn) {
      final user = await _authService.fetchCurrentUser();
      if (mounted) setState(() => _user = user);
    } else if (state.event == AuthChangeEvent.signedOut) {
      if (mounted) setState(() => _user = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Blind Ranking',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ],
          ),
        ),
      );
    }
    if (_user == null) {
      return AuthScreen(authService: _authService, onAuthenticated: _checkAuth);
    }
    return HomeScreen(
        user: _user!, lobbyService: _lobbyService, authService: _authService);
  }
}
