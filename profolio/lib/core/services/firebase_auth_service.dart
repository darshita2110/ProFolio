import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<UserCredential> signInWithGoogle();

  Future<void> signOut();

  Future<void> resetPassword({required String email});
}

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService(this._firebaseAuth)
      : _googleSignIn = GoogleSignIn();

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
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Sign out first to ensure account picker shows
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException(message: 'Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw AuthException(message: 'Failed to get Google authentication tokens');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(message: 'Google sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
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
      case 'invalid-credential':
        throw AuthException(message: 'Incorrect email or password');
      case 'too-many-requests':
        throw AuthException(message: 'Too many attempts. Please try again later');
      case 'network-request-failed':
        throw AuthException(message: 'Network error. Check your connection');
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