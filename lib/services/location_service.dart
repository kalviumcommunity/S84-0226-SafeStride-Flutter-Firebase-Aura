import 'package:geolocator/geolocator.dart';

/// Handles device location retrieval across Android, iOS, and Web.
/// Uses [geolocator] for all platforms (it handles browser geo-API on web too).
/// [permission_handler] is available in pubspec for other runtime permissions.
class LocationService {
  /// Default fallback coordinates (San Francisco) used when permission is
  /// denied or the location service is unavailable.
  static const double defaultLat = 37.7749;
  static const double defaultLng = -122.4194;

  /// Returns the device's current [Position].
  /// Silently falls back to [defaultLat]/[defaultLng] on any failure so the
  /// rest of the UI never sees an exception from this call.
  static Future<Position> getCurrentPosition() async {
    try {
      // 1. Check if the platform location service is enabled.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _fallback();

      // 2. Check / request runtime permission.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return _fallback();
      }
      if (permission == LocationPermission.deniedForever) return _fallback();

      // 3. Fetch actual position.
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return _fallback();
    }
  }

  static Position _fallback() => Position(
        latitude: defaultLat,
        longitude: defaultLng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
}
