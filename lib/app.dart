import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/app_setup/presentation/app_router.dart';
import 'features/app_setup/presentation/screens/app_initialization_screen.dart';
import 'features/settings/presentation/providers/theme_preference_provider.dart';

class AiCollegeCompanionApp extends ConsumerWidget {
  const AiCollegeCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ThemeMode> themeMode = ref.watch(themeModeProvider);
    final GoRouter router = ref.watch(appRouterProvider);

    return themeMode.when(
      data: (ThemeMode value) => MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: value,
        routerConfig: router,
      ),
      loading: () => const _BootstrapMaterialApp(
        child: AppInitializationScreen.loadingSettings(),
      ),
      error: (Object error, StackTrace stackTrace) => _BootstrapMaterialApp(
        child: AppInitializationScreen.settingsError(error),
      ),
    );
  }
}

class _BootstrapMaterialApp extends StatelessWidget {
  const _BootstrapMaterialApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: child,
    );
  }
}
