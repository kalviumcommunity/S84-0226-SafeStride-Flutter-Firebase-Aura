import '../models/route_model.dart';

/// A service that compares two [RouteModel] objects to help users decide 
/// which route is safer, more efficient, or better rated.
class RouteComparisonService {
  /// Compares two routes and returns the one with the highest safety score.
  static RouteModel getSaferRoute(RouteModel a, RouteModel b) {
    return a.safety >= b.safety ? a : b;
  }

  /// Compares two routes and returns the one with the highest rating.
  static RouteModel getBetterRatedRoute(RouteModel a, RouteModel b) {
    return a.rating >= b.rating ? a : b;
  }

  /// Compares two routes and returns the one with the shortest distance.
  /// Handles both 'km' and 'm' distance strings.
  static RouteModel getShorterRoute(RouteModel a, RouteModel b) {
    final distA = _parseDistanceKm(a.distance);
    final distB = _parseDistanceKm(b.distance);
    return distA <= distB ? a : b;
  }

  /// Returns a summary comparing the safety factors of two routes.
  static Map<String, dynamic> compareSafetyFactors(RouteModel a, RouteModel b) {
    return {
      'safer_route': getSaferRoute(a, b).name,
      'safety_diff': (a.safety - b.safety).abs(),
      'lighting_comparison': {
        a.name: a.lighting,
        b.name: b.lighting,
      },
      'traffic_comparison': {
        a.name: a.traffic,
        b.name: b.traffic,
      },
    };
  }

  /// Recommends a route based on a specific priority: 'safety', 'rating', or 'distance'.
  static RouteModel recommend(RouteModel a, RouteModel b, String priority) {
    switch (priority.toLowerCase()) {
      case 'safety':
        return getSaferRoute(a, b);
      case 'rating':
        return getBetterRatedRoute(a, b);
      case 'distance':
        return getShorterRoute(a, b);
      default:
        return getSaferRoute(a, b);
    }
  }

  static double _parseDistanceKm(String distance) {
    final text = distance.toLowerCase().trim();
    if (text.endsWith('km')) {
      return double.tryParse(text.replaceAll('km', '').trim()) ?? 9999.0;
    }
    if (text.endsWith('m')) {
      return (double.tryParse(text.replaceAll('m', '').trim()) ?? 999999.0) / 1000.0;
    }
    return 9999.0;
  }
}
