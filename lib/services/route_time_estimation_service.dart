import '../models/route_model.dart';

/// A service that provides time estimations for activities on a given route.
/// This considers activity types (running, cycling, walking) and environmental
/// factors that might affect speed.
class RouteTimeEstimationService {
  /// Default average speeds in km/h.
  static const double speedRunner = 10.0;
  static const double speedCyclist = 20.0;
  static const double speedWalker = 5.0;

  /// Estimates the duration in minutes for a route based on its category.
  static int estimateDurationMinutes(RouteModel route, {double? customSpeed}) {
    final distance = _parseDistanceKm(route.distance);
    if (distance <= 0) return 0;

    double speed = customSpeed ?? _getDefaultSpeed(route.category);
    
    // Adjust speed based on crowd levels (up to -15% if high crowd)
    final crowd = route.crowd.toLowerCase();
    if (crowd.contains('high')) {
      speed *= 0.85; 
    } else if (crowd.contains('moderate')) {
      speed *= 0.95;
    }

    final durationHours = distance / speed;
    return (durationHours * 60).round();
  }

  /// Returns a human-readable duration string (e.g., "45 mins", "1 hr 15 mins").
  static String formatDuration(int minutes) {
    if (minutes < 60) return '$minutes mins';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '$hours hr${hours > 1 ? 's' : ''}';
    return '$hours hr${hours > 1 ? 's' : ''} $remainingMinutes min${remainingMinutes > 1 ? 's' : ''}';
  }

  /// Calculates the estimated calories burned for the activity.
  /// (Simplified calculation: Weight 70kg assumed)
  static int estimateCalories(RouteModel route, int durationMinutes) {
    final category = route.category.toLowerCase();
    double met = 4.0; // Base MET for walking
    
    if (category.contains('runner')) {
      met = 9.8;
    } else if (category.contains('cyclist')) {
      met = 7.5;
    }

    // Formula: MET * 3.5 * weight(kg) / 200 * duration(min)
    return (met * 3.5 * 70.0 / 200.0 * durationMinutes).round();
  }

  static double _getDefaultSpeed(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('runner')) return speedRunner;
    if (cat.contains('cyclist')) return speedCyclist;
    return speedWalker;
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
