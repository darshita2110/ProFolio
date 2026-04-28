import 'package:firebase_auth/firebase_auth.dart';
import 'package:profolio/core/services/firebase_auth_service.dart';
import 'package:profolio/models/user_profile.dart';

abstract class IAuthRepository {
  Future<UserProfile?> registerWithEmail({required String email, required String password, required String name});
  Future<UserProfile?> signInWithEmail({required String email, required String password});
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
  Future<UserProfile?> registerWithEmail({required String email, required String password, required String name}) async {
    final cred = await authService.registerWithEmail(email: email, password: password);
    if (cred.user != null) {
      return UserProfile(id: cred.user!.uid, name: name, email: email,
          createdAt: DateTime.now(), updatedAt: DateTime.now());
    }
    return null;
  }

  @override
  Future<UserProfile?> signInWithEmail({required String email, required String password}) async {
    final cred = await authService.signInWithEmail(email: email, password: password);
    if (cred.user != null) {
      return UserProfile(id: cred.user!.uid, name: cred.user!.displayName ?? '', email: email);
    }
    return null;
  }

  @override Future<void> signOut() => authService.signOut();
  @override Future<void> resetPassword({required String email}) => authService.resetPassword(email: email);
  @override bool get isAuthenticated => authService.isAuthenticated;
  @override String? get currentUserId => authService.currentUserId;
  @override Stream<User?> get authStateChanges => authService.authStateChanges;
}