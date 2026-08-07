import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/app_user.dart';
import '../../../models/user_profile.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../auth/presentation/screens/forgot_password_screen.dart';
import '../../auth/presentation/screens/login_screen.dart';
import '../../auth/presentation/screens/onboarding_profile_screen.dart';
import '../../auth/presentation/screens/register_screen.dart';
import '../../dashboard/presentation/screens/dashboard_screen.dart';
import 'screens/app_initialization_screen.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AppUser?>>(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
    _ref.listen<AsyncValue<UserProfile?>>(
      userProfileProvider,
      (previous, next) => notifyListeners(),
    );
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final AsyncValue<AppUser?> authState = _ref.read(authStateProvider);
    final AppUser? user = authState.asData?.value;

    final String loc = state.matchedLocation;
    final bool isAuthRoute =
        loc == '/login' || loc == '/register' || loc == '/forgot-password';

    // 1. Unauthenticated state
    if (user == null) {
      if (loc == '/') return '/login';
      return isAuthRoute ? null : '/login';
    }

    // 2. Authenticated user state
    final AsyncValue<UserProfile?> profileAsync = _ref.read(userProfileProvider);

    if (profileAsync.isLoading) {
      return null;
    }

    final UserProfile? profile = profileAsync.asData?.value;
    final bool isProfileComplete = profile?.isProfileComplete ?? false;

    if (!isProfileComplete) {
      if (loc != '/onboarding') {
        return '/onboarding';
      }
      return null;
    }

    // 3. Authenticated + Complete profile
    if (isAuthRoute || loc == '/onboarding' || loc == '/') {
      return '/dashboard';
    }

    return null;
  }
}

final Provider<RouterNotifier> routerNotifierProvider = Provider<RouterNotifier>(
  (Ref ref) => RouterNotifier(ref),
);

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final RouterNotifier notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const AppInitializationScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingProfileScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});

late GoRouter appRouter;
