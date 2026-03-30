import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/route_time_estimation_service.dart';

void main() {
  group('RouteTimeEstimationService Tests', () {
    final runnerRoute = RouteModel(
      id: 1,
      name: 'Runner Route',
      category: 'Runner',
      distance: '10.0 km',
      safety: 90,
      lighting: 'Good',
      traffic: 'Low',
      crowd: 'Low',
      reviews: 50,
      rating: 4.8,
      image: 'img',
      emoji: '🏃',
    );

    final cyclistRoute = RouteModel(
      id: 2,
      name: 'Cyclist Path',
      category: 'Cyclist',
      distance: '20.0 km',
      safety: 85,
      lighting: 'Good',
      traffic: 'Moderate',
      crowd: 'High',
      reviews: 15,
      rating: 4.2,
      image: 'img',
      emoji: '🚴',
    );

    test('Should estimate correct duration for runner', () {
      // 10km / 10km/h = 1hr = 60 mins
      final mins = RouteTimeEstimationService.estimateDurationMinutes(runnerRoute);
      expect(mins, equals(60));
    });

    test('Should estimate correct duration for cyclist (adjusted for high crowd)', () {
      // 20km / (20km/h * 0.85) = 1.176 hr = ~71 mins
      final mins = RouteTimeEstimationService.estimateDurationMinutes(cyclistRoute);
      expect(mins, equals(71));
    });

    test('Should format duration correctly', () {
      expect(RouteTimeEstimationService.formatDuration(45), equals('45 mins'));
      expect(RouteTimeEstimationService.formatDuration(60), equals('1 hr'));
      expect(RouteTimeEstimationService.formatDuration(75), equals('1 hr 15 mins'));
      expect(RouteTimeEstimationService.formatDuration(120), equals('2 hrs'));
    });

    test('Should estimate calories correctly for runner', () {
      // MET (9.8) * 3.5 * 70 / 200 * 60 = 720.3 = 720
      final cals = RouteTimeEstimationService.estimateCalories(runnerRoute, 60);
      expect(cals, equals(720));
    });

    test('Should handle "m" distance correctly', () {
      final shortRoute = RouteModel(
        id: 3,
        name: 'Short Walk',
        category: 'Walker',
        distance: '5000 m',
        safety: 80,
        lighting: 'Average',
        traffic: 'Low',
        crowd: 'Low',
        reviews: 5,
        rating: 4.0,
        image: 'img',
        emoji: '🚶',
      );
      // 5000m = 5km / 5km/h = 1hr = 60 mins
      final mins = RouteTimeEstimationService.estimateDurationMinutes(shortRoute);
      expect(mins, equals(60));
    });
  });
}
