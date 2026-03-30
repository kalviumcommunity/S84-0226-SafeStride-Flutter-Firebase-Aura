import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/route_weather_impact_service.dart';

void main() {
  group('RouteWeatherImpactService Tests', () {
    final runnerRoute = RouteModel(
      id: 1,
      name: 'Runner Trail',
      category: 'Runner',
      distance: '5.0 km',
      safety: 95,
      lighting: 'Excellent',
      traffic: 'Low',
      crowd: 'Moderate',
      reviews: 50,
      rating: 4.8,
      image: 'img',
      emoji: '🏃',
    );

    final cyclistRoute = RouteModel(
      id: 2,
      name: 'Cyclist Path',
      category: 'Cyclist',
      distance: '15.0 km',
      safety: 90,
      lighting: 'Poor',
      traffic: 'High',
      crowd: 'Low',
      reviews: 30,
      rating: 4.2,
      image: 'img',
      emoji: '🚴',
    );

    test('Should adjust safety score correctly for Rainy weather', () {
      final score = RouteWeatherImpactService.getAdjustedSafetyScore(runnerRoute, 'Rainy');
      // Runner trail (95) + Rain (-20) = 75
      expect(score, equals(75));
    });

    test('Should adjust safety score correctly for Hot weather (Long distance)', () {
      final score = RouteWeatherImpactService.getAdjustedSafetyScore(cyclistRoute, 'Hot');
      // Cyclist path (90) + Hot & >10km (-15) = 75
      expect(score, equals(75));
    });

    test('Should adjust safety score correctly for Foggy weather (Poor lighting)', () {
      final score = RouteWeatherImpactService.getAdjustedSafetyScore(cyclistRoute, 'Foggy');
      // Cyclist path (90) + Fog & Poor lighting (-30) = 60
      expect(score, equals(60));
    });

    test('Should provide weather-specific safety tips', () {
      final runnerTips = RouteWeatherImpactService.getWeatherSafetyTips(runnerRoute, 'Rainy');
      final cyclistTips = RouteWeatherImpactService.getWeatherSafetyTips(cyclistRoute, 'Rainy');

      expect(runnerTips.any((t) => t.contains('Surfaces may be slippery.')), isTrue);
      expect(cyclistTips.any((t) => t.contains('Braking distances')), isTrue);
    });

    test('Should identify highly recommended routes for clear weather', () {
      final isRecommended = RouteWeatherImpactService.isHighlyRecommendedForWeather(runnerRoute, 'Clear');
      // Runner trail (95) + Clear (+5) = 100 >= 90
      expect(isRecommended, isTrue);
    });

    test('Should NOT recommend routes with poor safety for rainy weather', () {
      final isRecommended = RouteWeatherImpactService.isHighlyRecommendedForWeather(runnerRoute, 'Rainy');
      // Runner trail (95) + Rain (-20) = 75 < 90
      expect(isRecommended, isFalse);
    });
  });
}
