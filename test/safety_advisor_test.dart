import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/safety_advisor.dart';

void main() {
  group('SafetyAdvisor Tests', () {
    test('Should return high safety level for score 95+', () {
      expect(SafetyAdvisor.getSafetyLevel(95), 'Very Safe');
    });

    test('Should return caution advised for score below 70', () {
      expect(SafetyAdvisor.getSafetyLevel(65), 'Caution Advised');
    });

    test('Should recommend high visibility for high traffic routes', () {
      final route = RouteModel(
        id: 1,
        name: 'Busy Street',
        category: 'Runner',
        distance: '2.0 km',
        safety: 75,
        lighting: 'Good',
        traffic: 'High',
        crowd: 'Moderate',
        reviews: 10,
        rating: 4.0,
        image: 'img',
        emoji: '🏃',
      );

      final recommendations = SafetyAdvisor.getRecommendations(route);
      expect(recommendations, contains(contains('High traffic area: Use high-visibility gear')));
    });

    test('Should recommend sharing location for low crowd routes', () {
      final route = RouteModel(
        id: 2,
        name: 'Secluded Trail',
        category: 'Runner',
        distance: '5.0 km',
        safety: 85,
        lighting: 'Poor',
        traffic: 'Very Low',
        crowd: 'Low',
        reviews: 5,
        rating: 4.2,
        image: 'img',
        emoji: '🏃',
      );

      final recommendations = SafetyAdvisor.getRecommendations(route);
      expect(recommendations, contains(contains('It is recommended to share your live location')));
    });

    test('Should recommend headlamp for poor lighting', () {
      final route = RouteModel(
        id: 3,
        name: 'Night Trail',
        category: 'Runner',
        distance: '3.0 km',
        safety: 80,
        lighting: 'Poor',
        traffic: 'Low',
        crowd: 'Moderate',
        reviews: 20,
        rating: 4.5,
        image: 'img',
        emoji: '🏃',
      );

      final recommendations = SafetyAdvisor.getRecommendations(route);
      expect(recommendations, contains(contains('Bring a headlamp or flashlight')));
    });
  });
}
