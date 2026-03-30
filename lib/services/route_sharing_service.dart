import '../models/route_model.dart';

/// A service that formats route details for sharing via social media,
/// messaging apps, or emergency contacts.
class RouteSharingService {
  /// Returns a concise summary of the route for general sharing.
  static String formatRouteSummary(RouteModel route) {
    return 'Check out this route on SafeStride!\n'
        '📍 ${route.name} (${route.category})\n'
        '📏 Distance: ${route.distance}\n'
        '🛡️ Safety Score: ${route.safety}%\n'
        '⭐ Rating: ${route.rating}/5.0\n'
        '#SafeStride #SafetyFirst';
  }

  /// Returns a detailed safety report for sharing with friends or family.
  static String formatSafetyReport(RouteModel route) {
    return 'Hey, I wanted to share some safety details for this route:\n'
        'Route: ${route.name}\n'
        'Safety Score: ${route.safety}%\n'
        'Lighting: ${route.lighting}\n'
        'Traffic: ${route.traffic}\n'
        'Crowd Level: ${route.crowd}\n'
        'Shared via SafeStride';
  }

  /// Generates a Google Maps URL for the route location if coordinates are present.
  static String? getGoogleMapsUrl(RouteModel route) {
    if (route.latitude != null && route.longitude != null) {
      return 'https://www.google.com/maps/search/?api=1&query=${route.latitude},${route.longitude}';
    }
    return null;
  }

  /// Formats an emergency alert message with the current route and location.
  static String formatEmergencyAlert(RouteModel route) {
    final mapsUrl = getGoogleMapsUrl(route);
    final locationInfo = mapsUrl != null ? '\nLocation: $mapsUrl' : '';

    return 'EMERGENCY: I am on this route and need assistance.\n'
        'Route: ${route.name}$locationInfo\n'
        'Safety Score: ${route.safety}%\n'
        'PLEASE RESPOND IMMEDIATELY.';
  }
}
