import '../models/route_model.dart';

/// A service that calculates a granular safety score based on multiple environmental factors.
/// This provides a more objective safety assessment than a single manual score.
class SafetyScoreCalculator {
  /// Calculates a weighted safety score (0-100) based on route attributes.
  static int calculateWeightedScore(RouteModel route) {
    double score = 50.0; // Base score

    // Lighting weighting (up to +20 or -20)
    final lighting = route.lighting.toLowerCase();
    if (lighting.contains('excellent') || lighting.contains('bright')) {
      score += 20;
    } else if (lighting.contains('good')) {
      score += 10;
    } else if (lighting.contains('poor') || lighting.contains('dark')) {
      score -= 20;
    }

    // Traffic weighting (up to +15 or -15)
    final traffic = route.traffic.toLowerCase();
    if (traffic.contains('very low') || traffic.contains('none')) {
      score += 15;
    } else if (traffic.contains('low')) {
      score += 5;
    } else if (traffic.contains('high') || traffic.contains('heavy')) {
      score -= 15;
    }

    // Crowd weighting (up to +10 or -5)
    final crowd = route.crowd.toLowerCase();
    if (crowd.contains('moderate') || crowd.contains('high')) {
      score += 10; // More people usually means more safety (eyes on the street)
    } else if (crowd.contains('none') || crowd.contains('deserted')) {
      score -= 5;
    }

    // Rating & Reviews weighting (up to +5)
    if (route.rating >= 4.5 && route.reviews >= 50) {
      score += 5;
    }

    // Clamp score between 0 and 100
    return score.clamp(0, 100).round();
  }

  /// Returns a breakdown of the safety factors for transparency.
  static Map<String, String> getSafetyBreakdown(RouteModel route) {
    return {
      'Lighting Quality': route.lighting,
      'Traffic Volume': route.traffic,
      'Pedestrian Activity': route.crowd,
      'Community Trust': '${route.rating} stars (${route.reviews} reviews)',
    };
  }

  /// Suggests the best time to use the route based on its attributes.
  static String suggestBestTime(RouteModel route) {
    final lighting = route.lighting.toLowerCase();
    if (lighting.contains('poor') || lighting.contains('dark')) {
      return 'Best used during daylight hours (8 AM - 5 PM).';
    }
    if (route.traffic.toLowerCase().contains('high')) {
      return 'Best used during off-peak hours to avoid heavy traffic.';
    }
    return 'Suitable for use at any time of day.';
  }
}
