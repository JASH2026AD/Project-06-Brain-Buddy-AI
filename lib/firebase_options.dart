import 'package:firebase_core/firebase_core.dart';

/// Placeholder overwritten by `flutterfire configure` after Firebase setup.
abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Firebase has not been configured. Run flutterfire configure.',
  );
}
