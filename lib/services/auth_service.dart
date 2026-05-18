import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AppUser> signUpWithEmail({required String email, required String password, required String displayName}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;
    final appUser = AppUser(id: user.uid, email: email, displayName: displayName, isGuest: false);
    await _db.collection('profiles').doc(user.uid).set(appUser.toMap());
    return appUser;
  }

  Future<AppUser> signInWithEmail({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;
    final doc = await _db.collection('profiles').doc(user.uid).get();
    if (doc.exists) return AppUser.fromMap(user.uid, doc.data()!);
    final appUser = AppUser(id: user.uid, email: email, displayName: email.split('@').first, isGuest: false);
    await _db.collection('profiles').doc(user.uid).set(appUser.toMap());
    return appUser;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<AppUser> signInAsGuest({required String displayName}) async {
    final credential = await _auth.signInAnonymously();
    final user = credential.user!;
    final appUser = AppUser(id: user.uid, displayName: displayName, isGuest: true);
    await _db.collection('profiles').doc(user.uid).set(appUser.toMap());
    return appUser;
  }

  Future<AppUser?> fetchCurrentUser(User firebaseUser) async {
    try {
      final doc = await _db.collection('profiles').doc(firebaseUser.uid).get();
      if (doc.exists) return AppUser.fromMap(firebaseUser.uid, doc.data()!);
      return AppUser(id: firebaseUser.uid, email: firebaseUser.email, displayName: firebaseUser.email?.split('@').first ?? 'Gast', isGuest: firebaseUser.isAnonymous);
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async => await _auth.signOut();
}
