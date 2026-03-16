import '../models/route_model.dart';

/// A service that handles filtering and sorting for route discovery.
class DiscoveryEngine {
  /// Filters a list of [RouteModel] objects based on a search query and a 
  /// minimum safety score.
  static List<RouteModel> filterRoutes({
    required List<RouteModel> source,
    required String searchQuery,
    required int minSafetyFilter,
  }) {
    final query = searchQuery.toLowerCase().trim();
    
    return source.where((route) {
      // Apply search query filter
      final matchesQuery = query.isEmpty ||
          route.name.toLowerCase().contains(query) ||
          route.category.toLowerCase().contains(query);

      // Apply minimum safety score filter
      final matchesSafety = route.safety >= minSafetyFilter;

      return matchesQuery && matchesSafety;
    }).toList();
  }

  /// Sorts a list of [RouteModel] objects based on the selected category.
  static List<RouteModel> sortRoutes({
    required List<RouteModel> routes,
    required String selectedCategory,
  }) {
    final sorted = [...routes];
    
    switch (selectedCategory) {
      case 'safe':
        sorted.sort((a, b) => b.safety.compareTo(a.safety));
        break;
      case 'top':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'nearby':
        sorted.sort(
          (a, b) => _routeDistanceKm(a).compareTo(_routeDistanceKm(b)),
        );
        break;
      case 'trending':
      default:
        sorted.sort((a, b) => b.reviews.compareTo(a.reviews));
    }
    
    return sorted;
  }

  /// Helper to extract distance in KM from a route's distance string.
  static double _routeDistanceKm(RouteModel route) {
    final text = route.distance.toLowerCase().trim();
    if (text.endsWith('km')) {
      return double.tryParse(text.replaceAll('km', '').trim()) ?? 9999;
    }
    if (text.endsWith('m')) {
      final metres = double.tryParse(text.replaceAll('m', '').trim()) ?? 999999;
      return metres / 1000.0;
    }
    return 9999;
  }
}
