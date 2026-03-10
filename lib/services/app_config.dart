/// Secure compile-time configuration.
///
/// The API key is injected at build time via --dart-define, NOT stored in any
/// file bundled with the app. This means it cannot be extracted from the APK.
///
/// Build commands:
///   Debug:   flutter run  --dart-define=OPENAI_API_KEY=sk-proj-...
///   Release: flutter build apk --release --dart-define=OPENAI_API_KEY=sk-proj-...
///
/// In Android Studio / VS Code, add to launch configuration:
///   "args": ["--dart-define=OPENAI_API_KEY=sk-proj-..."]
class AppConfig {
  AppConfig._(); // not instantiable

  /// OpenAI API key — injected at compile time via --dart-define.
  /// Empty string if not provided (will throw at first API call).
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');

  /// Call once at app startup to catch missing key early.
  static void validate() {
    if (openAiApiKey.isEmpty) {
      throw StateError(
        'OPENAI_API_KEY is not set.\n'
        'Run with: flutter run --dart-define=OPENAI_API_KEY=your-key\n'
        'Or add it to your launch configuration in your IDE.',
      );
    }
  }
}

