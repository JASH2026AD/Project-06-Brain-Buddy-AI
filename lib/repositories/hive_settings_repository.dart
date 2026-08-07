import 'package:flutter/material.dart';

import '../services/hive_service.dart';
import 'settings_repository.dart';

class HiveSettingsRepository implements SettingsRepository {
  HiveSettingsRepository(this._hiveService);

  static const String _themeModeKey = 'theme_mode';
  final HiveService _hiveService;

  @override
  Future<ThemeMode> getThemeMode() async {
    final String? storedValue = _hiveService.readString(_themeModeKey);
    return ThemeMode.values.byName(storedValue ?? ThemeMode.system.name);
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) {
    return _hiveService.writeString(_themeModeKey, themeMode.name);
  }
}
