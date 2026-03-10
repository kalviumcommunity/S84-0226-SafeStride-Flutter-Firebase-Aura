import 'dart:async';

/// Stub implementation for non-web platforms.
/// This file is never actually called at runtime on mobile — the
/// conditional import in [MapsLoader] guarantees that.
Future<void> loadMapsScript(String apiKey) async {
  // No-op on mobile / desktop platforms.
}
