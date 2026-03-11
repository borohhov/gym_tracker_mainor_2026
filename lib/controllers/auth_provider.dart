import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _authSubscription = _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  String? get email => currentUser?.email;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String mapFirebaseAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already in use.';
        case 'invalid-email':
          return 'Invalid email format.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return error.message ?? 'Authentication error.';
      }
    }

    return 'Something went wrong. Please try again.';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}