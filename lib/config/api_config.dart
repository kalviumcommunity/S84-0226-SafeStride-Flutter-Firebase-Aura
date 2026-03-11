/// Central location for all third-party API keys and configuration.
class ApiConfig {
  const ApiConfig._();

  /// Google Maps API key.
  ///
  /// Used by:
  ///   • google_maps_flutter — renders the map tiles on Android, iOS, and Web
  ///   • web/index.html      — loads the Maps JavaScript API in the browser
  ///
  /// ⚠️  Nearby trail search uses the FREE OpenStreetMap Overpass API
  ///     and does NOT require this key or any paid Google service.
  ///
  /// Restrict this key in Google Cloud Console to:
  ///   • Maps SDK for Android (+ your app package name)
  ///   • Maps SDK for iOS     (+ your bundle ID)
  ///   • Maps JavaScript API  (+ your domain / localhost)
  static const String googleMapsApiKey =
      'AIzaSyBhyn_238QMqVbDwLRIDqRMt4YvDfl74_g';

  /// Legacy alias kept so existing call-sites that pass an apiKey parameter
  /// to PlacesService continue to compile without changes.
  /// The Overpass backend ignores this value.
  static const String googlePlacesApiKey = googleMapsApiKey;
}
