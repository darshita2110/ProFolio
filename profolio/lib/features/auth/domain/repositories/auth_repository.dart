import 'package:firebase_auth/firebase_auth.dart';
import 'package:profolio/core/services/firebase_auth_service.dart';
import 'package:profolio/models/user_profile.dart';

abstract class IAuthRepository {
  Future<UserProfile?> registerWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<UserProfile?> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserProfile?> signInWithGoogle();

  Future<void> signOut();

  Future<void> resetPassword({required String email});

  bool get isAuthenticated;
  String? get currentUserId;
  Stream<User?> get authStateChanges;
}

class AuthRepository implements IAuthRepository {
  final IAuthService authService;

  AuthRepository({required this.authService});

  @override
  Future<UserProfile?> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await authService.registerWithEmail(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return UserProfile(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      return null;
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<UserProfile?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return UserProfile(
          id: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? '',
          email: email,
        );
      }
      return null;
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<UserProfile?> signInWithGoogle() async {
    try {
      final userCredential = await authService.signInWithGoogle();
      final user = userCredential.user;

      if (user != null) {
        return UserProfile(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      return null;
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await authService.signOut();
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await authService.resetPassword(email: email);
    } on AuthException {
      rethrow;
    }
  }

  @override
  bool get isAuthenticated => authService.isAuthenticated;

  @override
  String? get currentUserId => authService.currentUserId;

  @override
  Stream<User?> get authStateChanges => authService.authStateChanges;
}