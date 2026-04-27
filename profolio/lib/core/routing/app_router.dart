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
      final isLoading = userAsyncValue.isLoading;
      if (isLoading) return null;

      final user = userAsyncValue.value;
      final isAuthed = user != null;
      final location = state.matchedLocation;

      if (!isAuthed) {
        // Not logged in — send to auth unless already there
        return location == AppRoutes.auth ? null : AppRoutes.auth;
      }

      // Logged in
      if (location == AppRoutes.auth) {
        // After login, go to profile (profile_screen handles onboarding redirect)
        return AppRoutes.profile;
      }

      return null;
    },
    initialLocation: AppRoutes.auth,
  );
});