abstract final class AppEnvironment {
  /// Public endpoint only. Gemini API keys stay exclusively in Cloud Functions.
  static const String aiProxyUrl = String.fromEnvironment('AI_PROXY_URL');

  static const bool useFirebaseEmulator = bool.fromEnvironment(
    'FIREBASE_USE_EMULATOR',
    defaultValue: false,
  );

  static bool get hasAiProxyUrl => aiProxyUrl.isNotEmpty;
}
