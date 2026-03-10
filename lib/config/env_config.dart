/// Compile-time environment configuration.
///
/// Values are injected via `--dart-define-from-file=.env` at build/run time.
/// Example:
///   flutter run --dart-define-from-file=.env -d chrome
///
/// This ensures secrets (API keys, etc.) are NEVER hardcoded in Dart source.
class EnvConfig {
  EnvConfig._(); // prevent instantiation

  /// Google Maps API key — used by the web Maps JS loader and any Dart-side
  /// geocoding / places calls.
  static const String mapsApiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: '',
  );

  /// Returns true when the Maps API key is available.
  static bool get hasMapsKey => mapsApiKey.isNotEmpty;
}
