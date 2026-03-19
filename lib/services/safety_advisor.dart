import '../models/route_model.dart';

/// A service that provides personalized safety recommendations based on route 
/// conditions such as lighting, traffic, and crowd levels.
class SafetyAdvisor {
  /// Generates a list of safety recommendations for a given [RouteModel].
  static List<String> getRecommendations(RouteModel route) {
    final recommendations = <String>[];

    // Lighting-based recommendations
    final lighting = route.lighting.toLowerCase();
    if (lighting.contains('poor') || lighting.contains('moderate')) {
      recommendations.add('Bring a headlamp or flashlight for better visibility.');
    } else if (lighting.contains('excellent')) {
      recommendations.add('Great lighting! This route is ideal for evening activities.');
    }

    // Traffic-based recommendations
    final traffic = route.traffic.toLowerCase();
    if (traffic.contains('high')) {
      recommendations.add('High traffic area: Use high-visibility gear and stay alert.');
    } else if (traffic.contains('moderate')) {
      recommendations.add('Be mindful of vehicles at intersections.');
    } else if (traffic.contains('low') || traffic.contains('very low')) {
      recommendations.add('Low traffic: Enjoy a quieter, safer environment.');
    }

    // Crowd-based recommendations
    final crowd = route.crowd.toLowerCase();
    if (crowd.contains('high')) {
      recommendations.add('Busy route: Watch out for other pedestrians and cyclists.');
    } else if (crowd.contains('low')) {
      recommendations.add('Secluded route: It is recommended to share your live location with a friend.');
    }

    // Safety score general advice
    if (route.safety < 80) {
      recommendations.add('This route has a lower safety score. Consider using it during peak daylight hours.');
    } else if (route.safety >= 95) {
      recommendations.add('Community-verified as highly safe! A top choice for solo outings.');
    }

    return recommendations;
  }

  /// Categorizes the safety of a route into a human-readable level.
  static String getSafetyLevel(int safetyScore) {
    if (safetyScore >= 90) return 'Very Safe';
    if (safetyScore >= 80) return 'Safe';
    if (safetyScore >= 70) return 'Moderate';
    return 'Caution Advised';
  }
}
