import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profolio/core/providers/firebase_providers.dart';
import 'package:profolio/features/auth/presentation/screens/auth_screen.dart';
import 'package:profolio/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:profolio/features/profile/presentation/screens/profile_screen.dart';

class AppRoutes {
  static const String auth = '/auth';
  static const String onboarding = '/onboarding';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final userAsyncValue = ref.watch(currentUserProvider);

  return GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const ProfileScreen(isEditing: true),
      ),
    ],
    redirect: (context, state) {
      final isAuth = userAsyncValue.whenData(
        (user) => user != null,
      ).value ?? false;

      final isLoading = userAsyncValue.isLoading;
      final isAuthScreen = state.matchedLocation == AppRoutes.auth;
      final isOnboardingScreen = state.matchedLocation == AppRoutes.onboarding;

      if (isLoading) return null;

      if (!isAuth) {
        return isAuthScreen ? null : AppRoutes.auth;
      }

      if (isAuthScreen) {
        return AppRoutes.profile;
      }

      return null;
    },
    initialLocation: AppRoutes.auth,
  );
});
