import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'env_config.dart';

// Conditional import — only pulls in dart:html on web.
import 'maps_loader_stub.dart'
    if (dart.library.html) 'maps_loader_web.dart' as platform;

/// Ensures the Google Maps JavaScript API is loaded before the first
/// [GoogleMap] widget renders.  Only does work on **web**; on mobile
/// platforms this is a no-op because the native SDK handles loading.
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

    final key = EnvConfig.mapsApiKey;
    if (key.isEmpty) {
      // ignore: avoid_print
      print('[MapsLoader] ⚠️  MAPS_API_KEY not set. '
          'Run with: flutter run --dart-define-from-file=.env');
      return;
    }

    await platform.loadMapsScript(key);
    _initialized = true;
  }
}
