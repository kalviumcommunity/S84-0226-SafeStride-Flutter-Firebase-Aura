import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/route_validation_service.dart';

void main() {
  group('RouteValidationService Tests', () {
    final validRoute = RouteModel(
      id: 1,
      name: 'Central Park Run',
      category: 'Runner',
      distance: '5.2 km',
      safety: 95,
      lighting: 'Excellent',
      traffic: 'None',
      crowd: 'High',
      reviews: 150,
      rating: 4.8,
      image: 'img.png',
      emoji: '🏃',
      latitude: 40.7850,
      longitude: -73.9682,
    );

    test('Should return valid for complete route data', () {
      final result = RouteValidationService.validateRoute(validRoute);
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('Should identify empty name error', () {
      final invalidRoute = RouteModel(
        id: 2,
        name: ' ',
        category: 'Walker',
        distance: '1.0 km',
        safety: 80,
        lighting: 'Good',
        traffic: 'Low',
        crowd: 'Low',
        reviews: 5,
        rating: 4.0,
        image: 'img',
        emoji: '🚶',
      );
      final result = RouteValidationService.validateRoute(invalidRoute);
      expect(result.isValid, isFalse);
      expect(result.errors, contains('Route name cannot be empty.'));
    });

    test('Should identify invalid safety score', () {
      final invalidRoute = RouteModel(
        id: 3,
        name: 'Dangerous Path',
        category: 'Runner',
        distance: '10.0 km',
        safety: 150, // Invalid
        lighting: 'Poor',
        traffic: 'High',
        crowd: 'None',
        reviews: 0,
        rating: 2.0,
        image: 'img',
        emoji: '⚠️',
      );
      final result = RouteValidationService.validateRoute(invalidRoute);
      expect(result.isValid, isFalse);
      expect(result.errors, contains('Safety score must be between 0 and 100.'));
    });

    test('Should identify high quality routes correctly', () {
      expect(RouteValidationService.isHighQuality(validRoute), isTrue);
      
      final lowQualityRoute = RouteModel(
        id: 4,
        name: 'Incomplete Route',
        category: 'Runner',
        distance: '5.0 km',
        safety: 60,
        lighting: 'Poor',
        traffic: 'High',
        crowd: 'None',
        reviews: 5,
        rating: 3.0,
        image: 'img',
        emoji: '🏃',
      );
      expect(RouteValidationService.isHighQuality(lowQualityRoute), isFalse);
    });

    test('Should filter a list of routes to return only valid ones', () {
      final routes = [
        validRoute,
        RouteModel(
          id: 5,
          name: '', // Invalid
          category: 'Walker',
          distance: '0 km',
          safety: 80,
          lighting: 'Good',
          traffic: 'Low',
          crowd: 'Low',
          reviews: 5,
          rating: 4.0,
          image: 'img',
          emoji: '🚶',
        ),
      ];
      final filtered = RouteValidationService.filterValidRoutes(routes);
      expect(filtered.length, equals(1));
      expect(filtered[0].name, equals('Central Park Run'));
    });
  });
}
