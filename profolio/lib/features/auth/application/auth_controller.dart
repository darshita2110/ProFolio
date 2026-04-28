import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profolio/core/providers/firebase_providers.dart';
import 'package:profolio/core/services/firebase_auth_service.dart';
import 'package:profolio/features/auth/domain/repositories/auth_repository.dart';
import 'package:profolio/models/user_profile.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(authService: ref.watch(authServiceProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;
  final UserProfile? userProfile;

  AuthState({this.isLoading = false, this.error, this.userProfile});

  AuthState copyWith({bool? isLoading, String? error, UserProfile? userProfile}) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        userProfile: userProfile ?? this.userProfile,
      );
}

class AuthController extends StateNotifier<AuthState> {
  final IAuthRepository repo;
  AuthController({required this.repo}) : super(AuthState());

  Future<void> registerWithEmail({required String email, required String password, required String name}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final p = await repo.registerWithEmail(email: email, password: password, name: name);
      state = state.copyWith(isLoading: false, userProfile: p);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> signInWithEmail({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final p = await repo.signInWithEmail(email: email, password: password);
      state = state.copyWith(isLoading: false, userProfile: p);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repo.signOut();
      state = AuthState();
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> resetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repo.resetPassword(email: email);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(repo: ref.watch(authRepositoryProvider));
});