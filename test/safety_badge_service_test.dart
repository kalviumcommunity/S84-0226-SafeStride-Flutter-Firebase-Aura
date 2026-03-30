import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/safety_badge_service.dart';

void main() {
  group('SafetyBadgeService Tests', () {
    final routeHigh = RouteModel(
      id: 1,
      name: 'Safe Path',
      category: 'Runner',
      distance: '5.0 km',
      safety: 98,
      lighting: 'Excellent',
      traffic: 'Very Low',
      crowd: 'High',
      reviews: 200,
      rating: 4.9,
      image: 'img.png',
      emoji: '🏃',
    );

    final routeSimple = RouteModel(
      id: 2,
      name: 'Simple Path',
      category: 'Walker',
      distance: '1.0 km',
      safety: 85,
      lighting: 'Average',
      traffic: 'Moderate',
      crowd: 'Moderate',
      reviews: 10,
      rating: 4.0,
      image: 'img',
      emoji: '🚶',
    );

    test('Should award multiple badges for high-performing route', () {
      final badges = SafetyBadgeService.getBadges(routeHigh);
      expect(badges.any((b) => b.name == 'Safety Star'), isTrue);
      expect(badges.any((b) => b.name == 'Community Favorite'), isTrue);
      expect(badges.any((b) => b.name == 'Night Owl'), isTrue);
      expect(badges.any((b) => b.name == 'Quiet Path'), isTrue);
      expect(badges.any((b) => b.name == 'Safe & Social'), isTrue);
    });

    test('Should award zero badges for route not meeting criteria', () {
      final badges = SafetyBadgeService.getBadges(routeSimple);
      expect(badges, isEmpty);
    });

    test('Should identify primary badge correctly by priority', () {
      final primary = SafetyBadgeService.getPrimaryBadge(routeHigh);
      expect(primary?.name, equals('Safety Star'));
    });

    test('Should return Night Owl badge for well-lit route', () {
      final litRoute = RouteModel(
        id: 3,
        name: 'Well Lit Path',
        category: 'Runner',
        distance: '3.0 km',
        safety: 80,
        lighting: 'Excellent',
        traffic: 'Low',
        crowd: 'Low',
        reviews: 5,
        rating: 4.0,
        image: 'img',
        emoji: '🏃',
      );
      final badges = SafetyBadgeService.getBadges(litRoute);
      expect(badges.any((b) => b.name == 'Night Owl'), isTrue);
      expect(badges.any((b) => b.name == 'Safety Star'), isFalse);
    });

    test('Should return Quiet Path for low traffic', () {
      final quietRoute = RouteModel(
        id: 4,
        name: 'Quiet Trail',
        category: 'Runner',
        distance: '5.0 km',
        safety: 80,
        lighting: 'Average',
        traffic: 'Very Low',
        crowd: 'None',
        reviews: 5,
        rating: 4.0,
        image: 'img',
        emoji: '🏃',
      );
      final badges = SafetyBadgeService.getBadges(quietRoute);
      expect(badges.any((b) => b.name == 'Quiet Path'), isTrue);
    });
  });
}
