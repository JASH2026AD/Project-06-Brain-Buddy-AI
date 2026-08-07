import 'package:go_router/go_router.dart';

import 'screens/app_initialization_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const AppInitializationScreen(),
    ),
  ],
);
