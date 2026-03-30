import '../models/route_model.dart';
import '../models/user_model.dart';

/// A service that recommends routes based on a user's profile and preferences.
class RouteRecommender {
  /// Returns a ranked list of recommended routes for a given user.
  /// Ranking is based on:
  /// 1. Matching activity type (runner/cyclist)
  /// 2. Proximity to preferred distance
  /// 3. High safety score
  static List<RouteModel> getRecommendations({
    required UserModel user,
    required List<RouteModel> availableRoutes,
    int limit = 5,
  }) {
    final scoredRoutes = availableRoutes.map((route) {
      double matchScore = 0.0;

      // 1. Activity Type Match (+40 pts)
      final userType = user.activityType.toLowerCase();
      final routeCategory = route.category.toLowerCase();
      if (routeCategory.contains(userType)) {
        matchScore += 40.0;
      }

      // 2. Distance Preference (+30 pts max)
      final routeDist = _parseDistanceKm(route.distance);
      final distDiff = (routeDist - user.preferredDistance).abs();
      // Points decrease as difference increases
      final distPoints = (30.0 - (distDiff * 2)).clamp(0.0, 30.0);
      matchScore += distPoints;

      // 3. Safety Score (+30 pts max)
      // Directly uses safety percentage as a weight (0.3 factor)
      matchScore += route.safety * 0.3;

      return _ScoredRoute(route: route, score: matchScore);
    }).toList();

    // Sort by score descending
    scoredRoutes.sort((a, b) => b.score.compareTo(a.score));

    return scoredRoutes.map((sr) => sr.route).take(limit).toList();
  }

  /// Calculates a "Match Percentage" (0-100) for a specific route and user.
  static int calculateMatchPercentage(UserModel user, RouteModel route) {
    final recommendations = getRecommendations(
      user: user,
      availableRoutes: [route],
    );
    if (recommendations.isEmpty) return 0;

    // A perfect match would score around 100 points
    // (40 for activity + 30 for distance + 30 for safety)
    final score = getRecommendationsWithScores(user: user, availableRoutes: [route]).first.score;
    return score.clamp(0.0, 100.0).round();
  }

  /// Internal helper to get scores along with routes.
  static List<_ScoredRoute> getRecommendationsWithScores({
    required UserModel user,
    required List<RouteModel> availableRoutes,
  }) {
    return availableRoutes.map((route) {
      double matchScore = 0.0;
      final userType = user.activityType.toLowerCase();
      final routeCategory = route.category.toLowerCase();
      if (routeCategory.contains(userType)) matchScore += 40.0;

      final routeDist = _parseDistanceKm(route.distance);
      final distDiff = (routeDist - user.preferredDistance).abs();
      matchScore += (30.0 - (distDiff * 2)).clamp(0.0, 30.0);
      matchScore += route.safety * 0.3;

      return _ScoredRoute(route: route, score: matchScore);
    }).toList();
  }

  static double _parseDistanceKm(String distance) {
    final text = distance.toLowerCase().trim();
    if (text.endsWith('km')) {
      return double.tryParse(text.replaceAll('km', '').trim()) ?? 0.0;
    }
    if (text.endsWith('m')) {
      return (double.tryParse(text.replaceAll('m', '').trim()) ?? 0.0) / 1000.0;
    }
    return 0.0;
  }
}

class _ScoredRoute {
  final RouteModel route;
  final double score;

  _ScoredRoute({required this.route, required this.score});
}
