import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  bool get isAuthenticated;

  String? get currentUserId;

  User? get currentUser;

  Stream<User?> get authStateChanges;

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  });

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resetPassword({required String email});
}

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService(this._firebaseAuth);

  @override
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      rethrow;
    }
  }

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign out failed');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      rethrow;
    }
  }

  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        throw AuthException(message: 'Password is too weak');
      case 'email-already-in-use':
        throw AuthException(message: 'Email is already in use');
      case 'invalid-email':
        throw AuthException(message: 'Invalid email format');
      case 'user-not-found':
        throw AuthException(message: 'User not found');
      case 'wrong-password':
        throw AuthException(message: 'Incorrect password');
      default:
        throw AuthException(message: e.message ?? 'Authentication error occurred');
    }
  }
}

class AuthException implements Exception {
  final String message;

  AuthException({required this.message});

  @override
  String toString() => message;
}
