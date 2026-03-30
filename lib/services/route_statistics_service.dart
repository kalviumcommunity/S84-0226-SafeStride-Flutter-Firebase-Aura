import '../models/route_model.dart';

/// A service that provides analytical insights on collections of [RouteModel].
/// Useful for dashboards, user activity summaries, and data-driven safety assessments.
class RouteStatisticsService {
  /// Calculates the average safety score of a list of routes.
  static double calculateAverageSafety(List<RouteModel> routes) {
    if (routes.isEmpty) return 0.0;
    final total = routes.fold<int>(0, (sum, route) => sum + route.safety);
    return total / routes.length;
  }

  /// Calculates the total distance covered by a list of routes in kilometers.
  /// Handles both 'km' and 'm' distance strings.
  static double calculateTotalDistanceKm(List<RouteModel> routes) {
    return routes.fold<double>(0.0, (sum, route) {
      final text = route.distance.toLowerCase().trim();
      if (text.endsWith('km')) {
        final value = double.tryParse(text.replaceAll('km', '').trim()) ?? 0.0;
        return sum + value;
      }
      if (text.endsWith('m')) {
        final value = double.tryParse(text.replaceAll('m', '').trim()) ?? 0.0;
        return sum + (value / 1000.0);
      }
      return sum;
    });
  }

  /// Identifies the most common route category in the provided list.
  static String? getMostCommonCategory(List<RouteModel> routes) {
    if (routes.isEmpty) return null;
    final categoryCounts = <String, int>{};
    for (final route in routes) {
      categoryCounts[route.category] = (categoryCounts[route.category] ?? 0) + 1;
    }
    return categoryCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// Returns the route with the highest safety score.
  /// If multiple have the same score, returns the first one found.
  static RouteModel? getSafestRoute(List<RouteModel> routes) {
    if (routes.isEmpty) return null;
    return routes.reduce((a, b) => a.safety >= b.safety ? a : b);
  }

  /// Returns the route with the highest user rating.
  static RouteModel? getTopRatedRoute(List<RouteModel> routes) {
    if (routes.isEmpty) return null;
    return routes.reduce((a, b) => a.rating >= b.rating ? a : b);
  }

  /// Groups routes by their safety level (Very Safe, Safe, Moderate, Caution).
  static Map<String, int> getSafetyDistribution(List<RouteModel> routes) {
    final distribution = {
      'Very Safe (90%+)': 0,
      'Safe (80-89%)': 0,
      'Moderate (70-79%)': 0,
      'Caution (<70%)': 0,
    };

    for (final route in routes) {
      if (route.safety >= 90) {
        distribution['Very Safe (90%+)'] = distribution['Very Safe (90%+)']! + 1;
      } else if (route.safety >= 80) {
        distribution['Safe (80-89%)'] = distribution['Safe (80-89%)']! + 1;
      } else if (route.safety >= 70) {
        distribution['Moderate (70-79%)'] = distribution['Moderate (70-79%)']! + 1;
      } else {
        distribution['Caution (<70%)'] = distribution['Caution (<70%)']! + 1;
      }
    }
    return distribution;
  }
}
