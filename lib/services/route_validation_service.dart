import '../models/route_model.dart';

/// A service dedicated to validating the integrity and quality of [RouteModel] data.
/// This ensures that only high-quality, complete data is used within the app.
class RouteValidationService {
  /// Validates the basic requirements for a route.
  static ValidationResult validateRoute(RouteModel route) {
    final errors = <String>[];

    if (route.name.trim().isEmpty) {
      errors.add('Route name cannot be empty.');
    }

    if (route.safety < 0 || route.safety > 100) {
      errors.add('Safety score must be between 0 and 100.');
    }

    if (route.rating < 0.0 || route.rating > 5.0) {
      errors.add('Rating must be between 0.0 and 5.0.');
    }

    final distanceValue = _parseDistance(route.distance);
    if (distanceValue <= 0) {
      errors.add('Route distance must be a positive value.');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Checks if a route is "high quality" (complete with location and good ratings).
  static bool isHighQuality(RouteModel route) {
    return route.latitude != null &&
        route.longitude != null &&
        route.safety >= 80 &&
        route.rating >= 4.0 &&
        route.reviews >= 10;
  }

  /// Validates a list of routes and returns only the valid ones.
  static List<RouteModel> filterValidRoutes(List<RouteModel> routes) {
    return routes.where((r) => validateRoute(r).isValid).toList();
  }

  static double _parseDistance(String distance) {
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

/// Represents the result of a validation operation.
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});

  String get errorMessage => errors.join(' ');
}
