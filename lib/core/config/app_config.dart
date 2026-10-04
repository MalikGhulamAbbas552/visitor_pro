abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static void validate() {
    if (supabaseUrl.isEmpty ||
        supabasePublishableKey.isEmpty) {
      throw StateError(
        'Supabase configuration missing.\n'
            'Run using:\n'
            'flutter run --dart-define-from-file=env/dev.json',
      );
    }
  }
}