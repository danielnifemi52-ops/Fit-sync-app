import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges,
);

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // Also sign out from Google if applicable
    // await GoogleSignIn().signOut();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // For Web, ensure the provider is configured
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // We can also add scopes if needed
      googleProvider.addScope('email');

      return await _auth.signInWithPopup(googleProvider);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error (${e.code}): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Generic Google Sign-In Error: $e');
      rethrow;
    }
  }

  /*
  Future<UserCredential?> signInWithApple() async {
    // 1. Trigger the Apple Authentication flow
    final appleProvider = AppleAuthProvider();
    // 2. Sign in
    return await _auth.signInWithProvider(appleProvider);
  }
  */
}
