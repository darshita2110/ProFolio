import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  bool get isAuthenticated;
  String? get currentUserId;
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<UserCredential> registerWithEmail({required String email, required String password});
  Future<UserCredential> signInWithEmail({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword({required String email});
}

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService(this._auth);

  @override bool get isAuthenticated => _auth.currentUser != null;
  @override String? get currentUserId => _auth.currentUser?.uid;
  @override User? get currentUser => _auth.currentUser;
  @override Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserCredential> registerWithEmail({required String email, required String password}) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) { _handle(e); rethrow; }
  }

  @override
  Future<UserCredential> signInWithEmail({required String email, required String password}) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) { _handle(e); rethrow; }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) { _handle(e); rethrow; }
  }

  void _handle(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':           throw AuthException(message: 'Password is too weak');
      case 'email-already-in-use':    throw AuthException(message: 'Email already in use');
      case 'invalid-email':           throw AuthException(message: 'Invalid email format');
      case 'user-not-found':          throw AuthException(message: 'No account with that email');
      case 'wrong-password':
      case 'invalid-credential':      throw AuthException(message: 'Incorrect email or password');
      case 'too-many-requests':       throw AuthException(message: 'Too many attempts — try later');
      case 'network-request-failed':  throw AuthException(message: 'Network error. Check connection');
      default:                        throw AuthException(message: e.message ?? 'Auth error');
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException({required this.message});
  @override String toString() => message;
}