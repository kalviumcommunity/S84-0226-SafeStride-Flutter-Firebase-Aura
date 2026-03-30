import '../models/route_model.dart';

/// A service that assesses the difficulty level of a [RouteModel] based on
/// distance and activity category.
class RouteDifficultyService {
  /// Possible difficulty levels.
  static const String levelEasy = 'Easy';
  static const String levelModerate = 'Moderate';
  static const String levelHard = 'Hard';
  static const String levelExpert = 'Expert';

  /// Assesses the difficulty level of a route based on its distance and category.
  static String getDifficultyLevel(RouteModel route) {
    final distance = _parseDistanceKm(route.distance);
    final category = route.category.toLowerCase();

    if (category.contains('runner')) {
      if (distance < 5.0) return levelEasy;
      if (distance <= 10.0) return levelModerate;
      if (distance <= 21.0) return levelHard;
      return levelExpert;
    } else if (category.contains('cyclist')) {
      if (distance < 10.0) return levelEasy;
      if (distance <= 30.0) return levelModerate;
      if (distance <= 60.0) return levelHard;
      return levelExpert;
    } else if (category.contains('walk')) {
      if (distance < 3.0) return levelEasy;
      if (distance <= 7.0) return levelModerate;
      if (distance <= 15.0) return levelHard;
      return levelExpert;
    }

    // Default assessment for unknown categories
    if (distance < 5.0) return levelEasy;
    if (distance <= 15.0) return levelModerate;
    return levelHard;
  }

  /// Returns a human-readable description of why a route has its difficulty level.
  static String getDifficultyDescription(RouteModel route) {
    final level = getDifficultyLevel(route);
    final category = route.category;
    final distance = route.distance;

    switch (level) {
      case levelEasy:
        return 'A light $category route covering $distance. Ideal for beginners or recovery.';
      case levelModerate:
        return 'A moderate $category challenge over $distance. Suitable for regular active users.';
      case levelHard:
        return 'A demanding $category route of $distance. Recommended for experienced users.';
      case levelExpert:
        return 'An endurance $category route of $distance. For high-level training only.';
      default:
        return 'A $level route for $category.';
    }
  }

  /// Suggests a "Safety Buffer" time in minutes based on difficulty.
  /// Harder routes should have more buffer time for unexpected delays.
  static int getRecommendedSafetyBufferMinutes(RouteModel route) {
    final level = getDifficultyLevel(route);
    switch (level) {
      case levelEasy:
        return 10;
      case levelModerate:
        return 20;
      case levelHard:
        return 45;
      case levelExpert:
        return 60;
      default:
        return 15;
    }
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
