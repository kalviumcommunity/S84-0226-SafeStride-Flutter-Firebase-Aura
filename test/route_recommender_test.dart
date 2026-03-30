import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/models/user_model.dart';
import 'package:safestride_app/services/route_recommender.dart';

void main() {
  group('RouteRecommender Tests', () {
    final user = UserModel(
      uid: 'user123',
      email: 'user@example.com',
      activityType: 'runner',
      preferredDistance: 5.0,
    );

    final route1 = RouteModel(
      id: 1,
      name: 'Perfect Match',
      category: 'Runner',
      distance: '5.0 km',
      safety: 100,
      lighting: 'Excellent',
      traffic: 'Low',
      crowd: 'Moderate',
      reviews: 50,
      rating: 4.8,
      image: 'img',
      emoji: '🏃',
    );

    final route2 = RouteModel(
      id: 2,
      name: 'Wrong Activity',
      category: 'Cyclist',
      distance: '5.0 km',
      safety: 100,
      lighting: 'Excellent',
      traffic: 'Low',
      crowd: 'Moderate',
      reviews: 50,
      rating: 4.8,
      image: 'img',
      emoji: '🚴',
    );

    final route3 = RouteModel(
      id: 3,
      name: 'Wrong Distance',
      category: 'Runner',
      distance: '20.0 km',
      safety: 100,
      lighting: 'Excellent',
      traffic: 'Low',
      crowd: 'Moderate',
      reviews: 50,
      rating: 4.8,
      image: 'img',
      emoji: '🏃',
    );

    test('Should rank perfect match first', () {
      final recommendations = RouteRecommender.getRecommendations(
        user: user,
        availableRoutes: [route1, route2, route3],
      );

      expect(recommendations.first.name, equals('Perfect Match'));
      expect(recommendations.length, equals(3));
    });

    test('Should calculate high match percentage for ideal route', () {
      final match = RouteRecommender.calculateMatchPercentage(user, route1);
      // Activity (40) + Distance (30) + Safety (30) = 100
      expect(match, equals(100));
    });

    test('Should calculate lower match percentage for wrong activity', () {
      final match = RouteRecommender.calculateMatchPercentage(user, route2);
      // No activity match (0) + Distance (30) + Safety (30) = 60
      expect(match, equals(60));
    });

    test('Should calculate lower match percentage for wrong distance', () {
      final match = RouteRecommender.calculateMatchPercentage(user, route3);
      // Activity match (40) + No distance points (0) + Safety (30) = 70
      expect(match, equals(70));
    });

    test('Should handle "m" distance correctly', () {
      final routeInMetres = RouteModel(
        id: 4,
        name: 'Short Metre Run',
        category: 'Runner',
        distance: '5000 m',
        safety: 100,
        lighting: 'Excellent',
        traffic: 'Low',
        crowd: 'Moderate',
        reviews: 50,
        rating: 4.8,
        image: 'img',
        emoji: '🏃',
      );
      final match = RouteRecommender.calculateMatchPercentage(user, routeInMetres);
      expect(match, equals(100));
    });
  });
}
