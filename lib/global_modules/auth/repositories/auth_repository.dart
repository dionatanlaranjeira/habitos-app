import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Contrato para autenticação.
abstract class AuthRepository {
  Stream<firebase_auth.User?> get authStateChanges;

  firebase_auth.User? get currentUser;

  Future<firebase_auth.UserCredential> signInWithEmail({
    required String email,
    required String password,
  });

  Future<firebase_auth.UserCredential> signInWithGoogle();

  Future<firebase_auth.UserCredential> signInWithApple();

  Future<void> signOut();
}
