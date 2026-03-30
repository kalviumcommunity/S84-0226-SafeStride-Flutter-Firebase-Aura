import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/route_comparison_service.dart';

void main() {
  group('RouteComparisonService Tests', () {
    final routeA = RouteModel(
      id: 1,
      name: 'Route A',
      category: 'Runner',
      distance: '5.0 km',
      safety: 95,
      lighting: 'Excellent',
      traffic: 'Very Low',
      crowd: 'Moderate',
      reviews: 100,
      rating: 4.8,
      image: 'img.png',
      emoji: '🏃',
    );

    final routeB = RouteModel(
      id: 2,
      name: 'Route B',
      category: 'Walker',
      distance: '2000 m',
      safety: 80,
      lighting: 'Good',
      traffic: 'Low',
      crowd: 'Low',
      reviews: 50,
      rating: 4.9,
      image: 'img',
      emoji: '🚶',
    );

    test('Should identify the safer route correctly', () {
      final safer = RouteComparisonService.getSaferRoute(routeA, routeB);
      expect(safer.name, equals('Route A'));
    });

    test('Should identify the better rated route correctly', () {
      final betterRated = RouteComparisonService.getBetterRatedRoute(routeA, routeB);
      expect(betterRated.name, equals('Route B'));
    });

    test('Should identify the shorter route correctly (handling km and m)', () {
      final shorter = RouteComparisonService.getShorterRoute(routeA, routeB);
      expect(shorter.name, equals('Route B')); // 2000m = 2km < 5km
    });

    test('Should provide a safety factors comparison map', () {
      final comparison = RouteComparisonService.compareSafetyFactors(routeA, routeB);
      expect(comparison['safer_route'], equals('Route A'));
      expect(comparison['safety_diff'], equals(15));
      expect(comparison['lighting_comparison']['Route A'], equals('Excellent'));
    });

    test('Should recommend based on safety priority', () {
      final recommendation = RouteComparisonService.recommend(routeA, routeB, 'safety');
      expect(recommendation.name, equals('Route A'));
    });

    test('Should recommend based on distance priority', () {
      final recommendation = RouteComparisonService.recommend(routeA, routeB, 'distance');
      expect(recommendation.name, equals('Route B'));
    });
  });
}
