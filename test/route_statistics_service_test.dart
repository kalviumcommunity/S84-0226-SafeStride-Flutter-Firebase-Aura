import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/route_statistics_service.dart';

void main() {
  group('RouteStatisticsService Tests', () {
    final routes = [
      RouteModel(
        id: 1,
        name: 'Safe Path',
        category: 'Runner',
        distance: '5.0 km',
        safety: 95,
        lighting: 'Bright',
        traffic: 'None',
        crowd: 'Low',
        reviews: 45,
        rating: 4.9,
        image: 'image.png',
        emoji: '🏃',
      ),
      RouteModel(
        id: 2,
        name: 'Moderate Path',
        category: 'Runner',
        distance: '2500 m',
        safety: 75,
        lighting: 'Average',
        traffic: 'Low',
        crowd: 'Moderate',
        reviews: 10,
        rating: 4.0,
        image: 'img',
        emoji: '🏃',
      ),
      RouteModel(
        id: 3,
        name: 'Caution Path',
        category: 'Cyclist',
        distance: '10.0 km',
        safety: 60,
        lighting: 'Poor',
        traffic: 'High',
        crowd: 'High',
        reviews: 5,
        rating: 3.5,
        image: 'img',
        emoji: '🚴',
      ),
    ];

    test('Should calculate correct average safety score', () {
      // (95 + 75 + 60) / 3 = 76.666...
      final avg = RouteStatisticsService.calculateAverageSafety(routes);
      expect(avg, closeTo(76.66, 0.01));
    });

    test('Should calculate total distance in KM (handling km and m)', () {
      // 5.0 km + 2.5 km (2500m) + 10.0 km = 17.5 km
      final total = RouteStatisticsService.calculateTotalDistanceKm(routes);
      expect(total, equals(17.5));
    });

    test('Should identify the most common category', () {
      final category = RouteStatisticsService.getMostCommonCategory(routes);
      expect(category, equals('Runner'));
    });

    test('Should find the safest route', () {
      final safest = RouteStatisticsService.getSafestRoute(routes);
      expect(safest?.name, equals('Safe Path'));
      expect(safest?.safety, equals(95));
    });

    test('Should find the top rated route', () {
      final topRated = RouteStatisticsService.getTopRatedRoute(routes);
      expect(topRated?.name, equals('Safe Path'));
      expect(topRated?.rating, equals(4.9));
    });

    test('Should provide a valid safety distribution map', () {
      final distribution = RouteStatisticsService.getSafetyDistribution(routes);
      expect(distribution['Very Safe (90%+)'], equals(1));
      expect(distribution['Moderate (70-79%)'], equals(1));
      expect(distribution['Caution (<70%)'], equals(1));
      expect(distribution['Safe (80-89%)'], equals(0));
    });
  });
}
