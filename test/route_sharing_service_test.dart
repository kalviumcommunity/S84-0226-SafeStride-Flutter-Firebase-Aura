import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/route_sharing_service.dart';

void main() {
  group('RouteSharingService Tests', () {
    final mockRoute = RouteModel(
      id: 1,
      name: 'Safe Path',
      category: 'Walker',
      distance: '1.2 km',
      safety: 98,
      lighting: 'Bright',
      traffic: 'None',
      crowd: 'Low',
      reviews: 45,
      rating: 4.9,
      image: 'image.png',
      emoji: '🚶',
      latitude: 40.7128,
      longitude: -74.0060,
    );

    test('Should format a valid route summary', () {
      final summary = RouteSharingService.formatRouteSummary(mockRoute);
      expect(summary, contains('Safe Path'));
      expect(summary, contains('98%'));
      expect(summary, contains('#SafeStride'));
    });

    test('Should format a valid safety report', () {
      final report = RouteSharingService.formatSafetyReport(mockRoute);
      expect(report, contains('Lighting: Bright'));
      expect(report, contains('Traffic: None'));
    });

    test('Should generate a valid Google Maps URL', () {
      final url = RouteSharingService.getGoogleMapsUrl(mockRoute);
      expect(url, equals('https://www.google.com/maps/search/?api=1&query=40.7128,-74.006'));
    });

    test('Should return null for missing coordinates', () {
      final incompleteRoute = RouteModel(
        id: 2,
        name: 'Incomplete Route',
        category: 'Runner',
        distance: '5.0 km',
        safety: 85,
        lighting: 'Average',
        traffic: 'Low',
        crowd: 'Moderate',
        reviews: 10,
        rating: 4.0,
        image: 'img',
        emoji: '🏃',
      );
      final url = RouteSharingService.getGoogleMapsUrl(incompleteRoute);
      expect(url, isNull);
    });

    test('Should format a valid emergency alert', () {
      final alert = RouteSharingService.formatEmergencyAlert(mockRoute);
      expect(alert, contains('EMERGENCY'));
      expect(alert, contains('Safe Path'));
      expect(alert, contains('Location: https://www.google.com/maps/search/?api=1&query=40.7128,-74.006'));
    });
  });
}
