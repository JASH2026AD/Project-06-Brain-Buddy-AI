import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/settings_repository.dart';
import '../../services/firebase_service.dart';
import '../../services/hive_service.dart';

final Provider<HiveService> hiveServiceProvider = Provider<HiveService>(
  (Ref ref) => throw UnimplementedError('HiveService must be overridden.'),
);

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
      (Ref ref) =>
          throw UnimplementedError('SettingsRepository must be overridden.'),
    );

final Provider<FirebaseService> firebaseServiceProvider =
    Provider<FirebaseService>((Ref ref) => FirebaseService());
