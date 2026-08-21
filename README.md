# AI College Compan

Flutter foundation for an offline-first college planner and Gemini-powered study companion.

## Phase 0 delivered

- Android, iOS, web, Windows, macOS, and Linux runner projects
- Material 3 light/dark themes using Inter from Google Fonts
- Riverpod composition root and asynchronous loading, success, and error states
- A Hive Community Edition local settings repository, selected because the original Hive package no longer supports the selected Dart 3.12 toolchain
- Firebase initialization service with a deliberate pre-configuration state
- Compile-time environment configuration that never exposes a Gemini API key to the app
- A clean-architecture baseline for core, features, repositories, services, widgets, models, and utilities

## Firebase setup (required before Phase 1)

1. Create a Firebase project in the [Firebase console](https://console.firebase.google.com/).
2. Register Android (`com.aicollegecompanion.ai_college_companion`), iOS, web, macOS, and Windows apps as applicable. Firebase does not have first-party Linux support; Linux uses the configured web/API path when Firebase-backed features are added.
3. Install the Firebase CLI and FlutterFire CLI:

   ```powershell
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```

4. In this project directory, authenticate and generate the real options file:

   ```powershell
   firebase login
   flutterfire configure
   ```

   This replaces `lib/firebase_options.dart`, which is intentionally a safe placeholder in the initial scaffold.

5. In Firebase Authentication, enable Email/Password and Google. Create Firestore, Storage, and Cloud Messaging when their respective phases begin.

## Environment values

Copy `.env.example.json` to `.env.json`; do not commit the copy. Use it at run time:

```powershell
flutter run --dart-define-from-file=.env.json
```

`AI_PROXY_URL` is only the public Cloud Function endpoint. Never place a Gemini API key in the Flutter app or in `.env.json`.

## Install and verify

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

## Structure

```text
lib/
  core/          # configuration, DI, strings, Material 3 theme
  features/      # feature presentation and state providers
  models/        # Freezed models introduced with their features
  repositories/  # testable repository contracts and Hive implementations
  services/      # Firebase, Hive, and network services
  widgets/       # reusable widgets introduced with their features
  utils/         # helpers and validators introduced with their features
```
