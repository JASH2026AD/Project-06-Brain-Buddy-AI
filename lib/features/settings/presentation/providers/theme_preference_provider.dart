import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';

final FutureProvider<ThemeMode> themeModeProvider = FutureProvider<ThemeMode>(
  (Ref ref) => ref.watch(settingsRepositoryProvider).getThemeMode(),
);
