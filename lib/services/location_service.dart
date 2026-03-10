import 'package:geolocator/geolocator.dart';

/// Enumerates every failure mode [LocationService.getCurrentLocation] can raise.
enum LocationServiceError {
  /// The device's system location toggle is off.
  servicesDisabled,

  /// The user tapped "Deny" on the permission prompt.
  permissionDenied,

  /// The user tapped "Deny & don't ask again" — the app can no longer request
  /// permission; the user must open device Settings manually.
  permissionDeniedForever,

  /// Any other unexpected error (timeout, hardware failure, etc.).
  unknown,
}

/// Thrown by [LocationService.getCurrentLocation] on every failure path so
/// callers receive a structured, human-readable error instead of a raw
/// platform exception.
class LocationServiceException implements Exception {
  const LocationServiceException(this.message, this.error);

  /// A user-facing description of what went wrong.
  final String message;

  /// Machine-readable category for programmatic handling (e.g. show a dialog
  /// directing the user to Settings when [error] is [LocationServiceError.permissionDeniedForever]).
  final LocationServiceError error;

  @override
  String toString() => 'LocationServiceException(${error.name}): $message';
}

/// Provides device-location access across Android, iOS, and Flutter Web.
///
/// All platform-specific permission flows are handled internally.
/// Callers should wrap [getCurrentLocation] in a `try/catch` and inspect the
/// [LocationServiceException.error] field to decide how to react in the UI.
///
/// Example:
/// ```dart
/// try {
///   final position = await LocationService.getCurrentLocation();
///   print('${position.latitude}, ${position.longitude}');
/// } on LocationServiceException catch (e) {
///   if (e.error == LocationServiceError.permissionDeniedForever) {
///     await Geolocator.openAppSettings();
///   }
/// }
/// ```
class LocationService {
  const LocationService._();

  /// Returns the device's current [Position] (latitude + longitude + metadata).
  ///
  /// Permission flow:
  /// 1. If location **services** are disabled → throws [LocationServiceError.servicesDisabled].
  /// 2. If permission is **denied** → requests it once.
  ///    - Still denied after prompt → throws [LocationServiceError.permissionDenied].
  /// 3. If permission is **permanently denied** → throws [LocationServiceError.permissionDeniedForever].
  /// 4. On any other platform error → throws [LocationServiceError.unknown].
  ///
  /// On **Flutter Web** the browser's native Geolocation API is used; the same
  /// permission flow applies (the browser will show its own permission prompt).
  static Future<Position> getCurrentLocation() async {
    // ── 1. Location Services ──────────────────────────────────────────────────
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        'Location services are disabled. Please enable them in your device settings.',
        LocationServiceError.servicesDisabled,
      );
    }

    // ── 2. Runtime Permission ─────────────────────────────────────────────────
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException(
          'Location permission was denied. Please grant location access to continue.',
          LocationServiceError.permissionDenied,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permission is permanently denied. '
        'Please enable it in your app settings.',
        LocationServiceError.permissionDeniedForever,
      );
    }

    // ── 3. Fetch Position ─────────────────────────────────────────────────────
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on Exception catch (e) {
      throw LocationServiceException(
        'Failed to retrieve location: $e',
        LocationServiceError.unknown,
      );
    }
  }

  /// Opens the device's location settings page so the user can re-enable
  /// location services. Call this when [LocationServiceError.servicesDisabled]
  /// is thrown and you want to guide the user.
  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();

  /// Opens the app's permission settings page. Call this when
  /// [LocationServiceError.permissionDeniedForever] is thrown.
  static Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
