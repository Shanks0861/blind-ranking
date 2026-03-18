import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

enum _AuthMode { login, register, guest }

class AuthScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onAuthenticated;

  const AuthScreen({
    super.key,
    required this.authService,
    required this.onAuthenticated,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _AuthMode _mode = _AuthMode.login;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _guestNameCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _guestNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.authService.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      widget.onAuthenticated();
    } catch (e) {
      setState(() => _error = 'E-Mail oder Passwort falsch.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (_emailCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty ||
        _nameCtrl.text.isEmpty) {
      setState(() => _error = 'Bitte alle Felder ausfüllen.');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _error = 'Passwort muss mindestens 6 Zeichen haben.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.authService.signUpWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
      // Wenn Email-Confirm aktiv: Session ist null, User muss Mail bestätigen
      final session = widget.authService.currentUser;
      if (session != null) {
        widget.onAuthenticated();
      } else {
        setState(() => _error = null);
        _setMode(_AuthMode.login);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '✅ Registrierung erfolgreich! Bitte bestätige deine E-Mail, dann kannst du dich einloggen.'),
              duration: Duration(seconds: 6),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('already registered') ||
          msg.contains('User already registered')) {
        setState(() => _error =
            'Diese E-Mail ist bereits registriert. Bitte logge dich ein.');
      } else {
        setState(() => _error = 'Registrierung fehlgeschlagen: $msg');
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleGuest() async {
    if (_guestNameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Bitte gib einen Namen ein.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.authService.signInAsGuest(
        displayName: _guestNameCtrl.text.trim(),
      );
      widget.onAuthenticated();
    } catch (e) {
      setState(() => _error = 'Gast-Login fehlgeschlagen: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _setMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo / Titel
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.leaderboard_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Blind Ranking',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            )),
                        Text('Multiplayer Party Game',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Mode Selector — 3 Buttons nebeneinander, flach
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _modeBtn(_AuthMode.login, 'Login'),
                      _modeBtn(_AuthMode.register, 'Registrieren'),
                      _modeBtn(_AuthMode.guest, 'Gast'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Form Card
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: _buildForm(),
                ),

                // Error
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withOpacity(0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeBtn(_AuthMode mode, String label) {
    final active = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.textSecondary,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    switch (_mode) {
      case _AuthMode.login:
        return _buildCard(
          key: const ValueKey('login'),
          children: [
            _field(
                controller: _emailCtrl,
                label: 'E-Mail',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _passwordField(),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  if (_emailCtrl.text.isNotEmpty) {
                    await widget.authService
                        .sendPasswordReset(_emailCtrl.text.trim());
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Reset-Mail wurde gesendet!')),
                      );
                    }
                  } else {
                    setState(() => _error = 'Bitte E-Mail eingeben.');
                  }
                },
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text('Passwort vergessen?',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 20),
            _submitBtn('Einloggen', _handleLogin),
          ],
        );

      case _AuthMode.register:
        return _buildCard(
          key: const ValueKey('register'),
          children: [
            _field(
                controller: _nameCtrl,
                label: 'Anzeigename',
                icon: Icons.person_outline),
            const SizedBox(height: 14),
            _field(
                controller: _emailCtrl,
                label: 'E-Mail',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _passwordField(),
            const SizedBox(height: 6),
            const Text('  mind. 6 Zeichen',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 20),
            _submitBtn('Account erstellen', _handleRegister),
          ],
        );

      case _AuthMode.guest:
        return _buildCard(
          key: const ValueKey('guest'),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.flash_on_rounded,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kein Account nötig. Spiele sofort los – ohne Registrierung.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _field(
                controller: _guestNameCtrl,
                label: 'Dein Name im Spiel',
                icon: Icons.emoji_emotions_outlined),
            const SizedBox(height: 20),
            _submitBtn('Als Gast spielen', _handleGuest),
          ],
        );
    }
  }

  Widget _buildCard({required List<Widget> children, required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Passwort',
        prefixIcon: const Icon(Icons.lock_outline,
            color: AppColors.textSecondary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _submitBtn(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}
