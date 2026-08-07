import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveService {
  static const String _settingsBoxName = 'settings';
  late final Box<String> _settingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox<String>(_settingsBoxName);
  }

  String? readString(String key) => _settingsBox.get(key);

  Future<void> writeString(String key, String value) {
    return _settingsBox.put(key, value);
  }
}
