import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/route_difficulty_service.dart';

void main() {
  group('RouteDifficultyService Tests', () {
    final easyRunner = RouteModel(
      id: 1,
      name: 'Easy Run',
      category: 'Runner',
      distance: '3.0 km',
      safety: 95,
      lighting: 'Excellent',
      traffic: 'None',
      crowd: 'Moderate',
      reviews: 20,
      rating: 4.8,
      image: 'img',
      emoji: '🏃',
    );

    final moderateCyclist = RouteModel(
      id: 2,
      name: 'Moderate Cycle',
      category: 'Cyclist',
      distance: '25.0 km',
      safety: 85,
      lighting: 'Good',
      traffic: 'Low',
      crowd: 'Low',
      reviews: 15,
      rating: 4.2,
      image: 'img',
      emoji: '🚴',
    );

    final hardWalker = RouteModel(
      id: 3,
      name: 'Hard Walk',
      category: 'Walk',
      distance: '12.0 km',
      safety: 80,
      lighting: 'Average',
      traffic: 'Low',
      crowd: 'Low',
      reviews: 5,
      rating: 4.0,
      image: 'img',
      emoji: '🚶',
    );

    test('Should assess difficulty levels correctly', () {
      expect(RouteDifficultyService.getDifficultyLevel(easyRunner), equals('Easy'));
      expect(RouteDifficultyService.getDifficultyLevel(moderateCyclist), equals('Moderate'));
      expect(RouteDifficultyService.getDifficultyLevel(hardWalker), equals('Hard'));
    });

    test('Should provide accurate difficulty descriptions', () {
      final description = RouteDifficultyService.getDifficultyDescription(easyRunner);
      expect(description, contains('Ideal for beginners'));
      expect(description, contains('3.0 km'));
    });

    test('Should recommend appropriate safety buffers', () {
      expect(RouteDifficultyService.getRecommendedSafetyBufferMinutes(easyRunner), equals(10));
      expect(RouteDifficultyService.getRecommendedSafetyBufferMinutes(moderateCyclist), equals(20));
      expect(RouteDifficultyService.getRecommendedSafetyBufferMinutes(hardWalker), equals(45));
    });

    test('Should handle "m" distance correctly in difficulty assessment', () {
      final shortCyclist = RouteModel(
        id: 4,
        name: 'Short Cycle',
        category: 'Cyclist',
        distance: '5000 m',
        safety: 90,
        lighting: 'Good',
        traffic: 'None',
        crowd: 'Low',
        reviews: 5,
        rating: 4.5,
        image: 'img',
        emoji: '🚴',
      );
      // 5000m = 5km < 10km (Easy for cyclist)
      expect(RouteDifficultyService.getDifficultyLevel(shortCyclist), equals('Easy'));
    });
  });
}
