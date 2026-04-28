import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profolio/core/providers/firebase_providers.dart';
import 'package:profolio/features/auth/presentation/screens/auth_screen.dart';
import 'package:profolio/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:profolio/features/profile/presentation/screens/profile_screen.dart';

class AppRoutes {
  static const String auth        = '/auth';
  static const String onboarding  = '/onboarding';
  static const String profile     = '/profile';
  static const String editProfile = '/edit-profile';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return GoRouter(
    routes: [
      GoRoute(path: AppRoutes.auth,
          builder: (_, __) => const AuthScreen()),
      GoRoute(path: AppRoutes.onboarding,
          builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.profile,
          builder: (_, __) => const ProfileScreen()),
      GoRoute(path: AppRoutes.editProfile,
          builder: (_, __) => const ProfileScreen(isEditing: true)),
    ],
    redirect: (context, state) {
      if (userAsync.isLoading) return null;
      final authed   = userAsync.value != null;
      final location = state.matchedLocation;
      if (!authed) return location == AppRoutes.auth ? null : AppRoutes.auth;
      if (location == AppRoutes.auth) return AppRoutes.profile;
      return null;
    },
    initialLocation: AppRoutes.auth,
  );
});