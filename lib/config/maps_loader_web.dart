import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Dynamically injects the Google Maps JavaScript API `<script>` tag
/// into the page's `<head>`.  Resolves when the script has fully loaded.
Future<void> loadMapsScript(String apiKey) async {
  // Don't double-inject if someone already placed the tag in index.html.
  final existing = html.document.querySelector(
      'script[src*="maps.googleapis.com/maps/api/js"]');
  if (existing != null) return;

  final completer = Completer<void>();

  // Build the script URL and create the element.
  // dart:html's ScriptElement.async is a getter (always true for dynamic scripts)
  // so we just set the src and let the browser handle async loading.
  final script = html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
    ..type = 'text/javascript';

  script.onLoad.listen((_) => completer.complete());
  script.onError.listen((_) {
    // ignore: avoid_print
    print('[MapsLoader] ❌ Failed to load Google Maps JS API');
    completer.complete(); // Don't block the app — show fallback instead
  });

  html.document.head!.append(script);
  await completer.future;
}
