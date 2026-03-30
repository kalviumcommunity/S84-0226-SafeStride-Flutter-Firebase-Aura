import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/alert_analysis_service.dart';

void main() {
  group('AlertAnalysisService Tests', () {
    final alerts = [
      AlertModel(
        id: 1,
        type: 'Safety',
        title: 'Poor Lighting',
        message: 'Several streetlights are out.',
        location: 'Riverside Trail',
        time: '10 mins ago',
        color: 'red',
      ),
      AlertModel(
        id: 2,
        type: 'Weather',
        title: 'Heavy Rain',
        message: 'Path may be slippery.',
        location: 'Mountain Loop',
        time: '30 mins ago',
        color: 'orange',
      ),
      AlertModel(
        id: 3,
        type: 'Traffic',
        title: 'Road Work',
        message: 'Partial closure at main gate.',
        location: 'Riverside Trail',
        time: '1 hour ago',
        color: 'blue',
      ),
      AlertModel(
        id: 4,
        type: 'Danger',
        title: 'High Water',
        message: 'Flood warning in effect.',
        location: 'River Bank',
        time: '5 mins ago',
        color: 'red',
      ),
    ];

    test('Should identify high severity alerts correctly', () {
      final highSeverity = AlertAnalysisService.getHighSeverityAlerts(alerts);
      expect(highSeverity.length, equals(2));
      expect(highSeverity[0].title, equals('Poor Lighting'));
      expect(highSeverity[1].title, equals('High Water'));
    });

    test('Should group alerts by their type', () {
      final grouped = AlertAnalysisService.groupAlertsByType(alerts);
      expect(grouped['Safety']?.length, equals(1));
      expect(grouped['Weather']?.length, equals(1));
      expect(grouped['Traffic']?.length, equals(1));
      expect(grouped['Danger']?.length, equals(1));
    });

    test('Should filter alerts by location', () {
      final riversideAlerts = AlertAnalysisService.getAlertsByLocation(alerts, 'Riverside');
      expect(riversideAlerts.length, equals(2));
      expect(riversideAlerts[0].location, equals('Riverside Trail'));
    });

    test('Should determine correct severity level from color', () {
      expect(AlertAnalysisService.getSeverityLevel(alerts[0]), equals('Critical')); // red
      expect(AlertAnalysisService.getSeverityLevel(alerts[1]), equals('Warning')); // orange
      expect(AlertAnalysisService.getSeverityLevel(alerts[2]), equals('Information')); // blue
    });

    test('Should provide alert statistics', () {
      final stats = AlertAnalysisService.getAlertStatistics(alerts);
      expect(stats['Safety'], equals(1));
      expect(stats['Weather'], equals(1));
      expect(stats['Traffic'], equals(1));
      expect(stats['Danger'], equals(1));
    });

    test('Should return unique affected locations', () {
      final locations = AlertAnalysisService.getAffectedLocations(alerts);
      expect(locations.length, equals(3));
      expect(locations, contains('Riverside Trail'));
      expect(locations, contains('Mountain Loop'));
      expect(locations, contains('River Bank'));
    });
  });
}
