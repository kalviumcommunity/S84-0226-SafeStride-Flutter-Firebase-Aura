import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_config.dart';
import 'env_config.dart';

// Conditional import — only pulls in dart:html on web.
import 'maps_loader_stub.dart'
    if (dart.library.html) 'maps_loader_web.dart'
    as platform;

/// Ensures the Google Maps JavaScript API is loaded before the first
/// [GoogleMap] widget renders.  Only does work on **web**; on mobile
/// platforms this is a no-op because the native SDK handles loading.
///
/// The API key is resolved in this order:
///   1. Env var via `--dart-define=MAPS_API_KEY=...` or `--dart-define-from-file=.env`
///   2. Hardcoded fallback from [ApiConfig.googleMapsApiKey]
///
/// Call once from `main()`:
/// ```dart
/// await MapsLoader.ensureInitialized();
/// ```
class MapsLoader {
  MapsLoader._();

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (!kIsWeb) {
      _initialized = true;
      return; // Native SDK loaded via Gradle / CocoaPods
    }

    // Prefer env-injected key; fall back to the hardcoded key in ApiConfig.
    final key = EnvConfig.mapsApiKey.isNotEmpty
        ? EnvConfig.mapsApiKey
        : ApiConfig.googleMapsApiKey;

    if (key.isEmpty) {
      // ignore: avoid_print
      print('[MapsLoader] ⚠️  No Maps API key available.');
      _initialized = true;
      return;
    }

    await platform.loadMapsScript(key);
    _initialized = true;
  }
}
