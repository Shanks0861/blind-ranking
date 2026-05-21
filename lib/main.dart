import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/app_user.dart';
import 'services/auth_service.dart';
import 'services/lobby_service.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/lobby/home_screen.dart';
import 'utils/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Fix für Flutter Web — verhindert WebChannel CORS Fehler
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    sslEnabled: true,
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
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        if (mounted) setState(() { _user = null; _checking = false; });
      } else {
        final user = await _authService.fetchCurrentUser(firebaseUser);
        if (mounted) setState(() { _user = user; _checking = false; });
      }
    });
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
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ],
          ),
        ),
      );
    }
    if (_user == null) {
      return AuthScreen(authService: _authService, onAuthenticated: () {});
    }
    return HomeScreen(user: _user!, lobbyService: _lobbyService, authService: _authService);
  }
}