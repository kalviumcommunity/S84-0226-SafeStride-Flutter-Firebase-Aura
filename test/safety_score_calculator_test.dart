import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/safety_score_calculator.dart';

void main() {
  group('SafetyScoreCalculator Tests', () {
    final routeHigh = RouteModel(
      id: 1,
      name: 'Safe Path',
      category: 'Runner',
      distance: '5.0 km',
      safety: 90,
      lighting: 'Excellent',
      traffic: 'Very Low',
      crowd: 'Moderate',
      reviews: 100,
      rating: 4.8,
      image: 'img.png',
      emoji: '🏃',
    );

    final routeLow = RouteModel(
      id: 2,
      name: 'Dark Path',
      category: 'Walker',
      distance: '2.0 km',
      safety: 60,
      lighting: 'Poor',
      traffic: 'High',
      crowd: 'None',
      reviews: 5,
      rating: 3.0,
      image: 'img',
      emoji: '🚶',
    );

    test('Should calculate a high weighted safety score for ideal conditions', () {
      // Base (50) + Excellent (20) + Very Low Traffic (15) + Moderate Crowd (10) + High Rating/Reviews (5) = 100
      final score = SafetyScoreCalculator.calculateWeightedScore(routeHigh);
      expect(score, equals(100));
    });

    test('Should calculate a low weighted safety score for poor conditions', () {
      // Base (50) + Poor Lighting (-20) + High Traffic (-15) + No Crowd (-5) = 10
      final score = SafetyScoreCalculator.calculateWeightedScore(routeLow);
      expect(score, equals(10));
    });

    test('Should provide a valid safety factor breakdown', () {
      final breakdown = SafetyScoreCalculator.getSafetyBreakdown(routeHigh);
      expect(breakdown['Lighting Quality'], equals('Excellent'));
      expect(breakdown['Traffic Volume'], equals('Very Low'));
      expect(breakdown['Pedestrian Activity'], equals('Moderate'));
      expect(breakdown['Community Trust'], contains('4.8 stars (100 reviews)'));
    });

    test('Should suggest best usage time based on lighting', () {
      final suggestionHigh = SafetyScoreCalculator.suggestBestTime(routeHigh);
      final suggestionLow = SafetyScoreCalculator.suggestBestTime(routeLow);

      expect(suggestionHigh, contains('any time of day'));
      expect(suggestionLow, contains('daylight hours'));
    });
  });
}
