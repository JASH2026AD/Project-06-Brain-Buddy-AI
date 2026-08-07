import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../repositories/settings_repository.dart';

class ThemePreferenceNotifier extends Notifier<AsyncValue<ThemeMode>> {
  @override
  AsyncValue<ThemeMode> build() {
    _loadThemeMode();
    return const AsyncValue.loading();
  }

  SettingsRepository get _settingsRepo =>
      ref.read(settingsRepositoryProvider);

  Future<void> _loadThemeMode() async {
    try {
      final ThemeMode mode = await _settingsRepo.getThemeMode();
      state = AsyncValue.data(mode);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncValue.data(mode);
    try {
      await _settingsRepo.saveThemeMode(mode);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }
}

final NotifierProvider<ThemePreferenceNotifier, AsyncValue<ThemeMode>>
    themeModeProvider =
    NotifierProvider<ThemePreferenceNotifier, AsyncValue<ThemeMode>>(
  ThemePreferenceNotifier.new,
);
