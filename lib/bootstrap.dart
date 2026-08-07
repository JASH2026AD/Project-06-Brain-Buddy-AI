import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/app_providers.dart';
import 'repositories/hive_settings_repository.dart';
import 'services/hive_service.dart';

typedef AppBuilder = Widget Function();

Future<void> bootstrap(AppBuilder builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  final HiveService hiveService = HiveService();
  await hiveService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        settingsRepositoryProvider.overrideWithValue(
          HiveSettingsRepository(hiveService),
        ),
      ],
      child: builder(),
    ),
  );
}
