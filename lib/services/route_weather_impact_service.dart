import '../models/route_model.dart';

/// A service that analyzes how different weather conditions impact route safety.
/// This provides users with a dynamic safety assessment based on the current 
/// or forecasted weather.
class RouteWeatherImpactService {
  /// Calculates a modified safety score based on a given weather condition.
  /// Weather conditions can be: 'Rainy', 'Hot', 'Foggy', 'Clear'.
  static int getAdjustedSafetyScore(RouteModel route, String weatherCondition) {
    double impactFactor = 0.0;
    final condition = weatherCondition.toLowerCase();
    final category = route.category.toLowerCase();
    final lighting = route.lighting.toLowerCase();

    if (condition.contains('rain')) {
      // Rainy weather has a high impact on nature trails (Runner)
      impactFactor = category.contains('runner') ? -20.0 : -10.0;
    } else if (condition.contains('hot') || condition.contains('heat')) {
      // Hot weather impacts longer routes more (Distance)
      final distance = _parseDistanceKm(route.distance);
      impactFactor = distance > 10.0 ? -15.0 : -5.0;
    } else if (condition.contains('fog')) {
      // Foggy weather is highly dangerous for poorly lit routes
      if (lighting.contains('poor') || lighting.contains('dark')) {
        impactFactor = -30.0;
      } else {
        impactFactor = -15.0;
      }
    } else if (condition.contains('clear')) {
      // Clear weather is ideal, potentially a small bonus
      impactFactor = 5.0;
    }

    return (route.safety + impactFactor).clamp(0, 100).round();
  }

  /// Provides weather-specific safety tips for a given route.
  static List<String> getWeatherSafetyTips(RouteModel route, String weatherCondition) {
    final tips = <String>[];
    final condition = weatherCondition.toLowerCase();
    final category = route.category.toLowerCase();

    if (condition.contains('rain')) {
      tips.add('Surfaces may be slippery. Use footwear with extra grip.');
      if (category.contains('cyclist')) {
        tips.add('Braking distances are increased on wet roads.');
      }
    } else if (condition.contains('hot')) {
      tips.add('High temperature: Carry at least 500ml of water.');
      tips.add('Apply sunscreen and wear a hat.');
    } else if (condition.contains('fog')) {
      tips.add('Reduced visibility: Wear high-visibility or reflective gear.');
      tips.add('Stay on well-defined paths to avoid getting lost.');
    }

    return tips;
  }

  /// Determines if a route is "Highly Recommended" for the given weather.
  static bool isHighlyRecommendedForWeather(RouteModel route, String weatherCondition) {
    final adjustedScore = getAdjustedSafetyScore(route, weatherCondition);
    // Highly recommended if adjusted score is still very high (90+)
    return adjustedScore >= 90;
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
