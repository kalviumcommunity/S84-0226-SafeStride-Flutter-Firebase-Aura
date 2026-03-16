import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/discovery_engine.dart';

void main() {
  group('DiscoveryEngine Tests', () {
    final mockRoutes = [
      RouteModel(
        id: 1,
        name: 'Safe Park Walk',
        category: 'Walk',
        distance: '2.5 km',
        safety: 95,
        lighting: 'Excellent',
        traffic: 'Low',
        crowd: 'Moderate',
        reviews: 120,
        rating: 4.8,
        image: 'park',
        emoji: '🌳',
      ),
      RouteModel(
        id: 2,
        name: 'Busy Street Run',
        category: 'Run',
        distance: '500 m',
        safety: 65,
        lighting: 'Moderate',
        traffic: 'High',
        crowd: 'High',
        reviews: 45,
        rating: 3.2,
        image: 'street',
        emoji: '🏃',
      ),
      RouteModel(
        id: 3,
        name: 'Quiet Trail',
        category: 'Trail',
        distance: '5 km',
        safety: 88,
        lighting: 'Good',
        traffic: 'None',
        crowd: 'Low',
        reviews: 80,
        rating: 4.5,
        image: 'trail',
        emoji: '⛰️',
      ),
    ];

    test('filterRoutes should filter by search query', () {
      final results = DiscoveryEngine.filterRoutes(
        source: mockRoutes,
        searchQuery: 'park',
        minSafetyFilter: 0,
      );
      expect(results.length, 1);
      expect(results.first.name, 'Safe Park Walk');
    });

    test('filterRoutes should be case-insensitive', () {
      final results = DiscoveryEngine.filterRoutes(
        source: mockRoutes,
        searchQuery: 'PARK',
        minSafetyFilter: 0,
      );
      expect(results.length, 1);
      expect(results.first.name, 'Safe Park Walk');
    });

    test('filterRoutes should filter by minimum safety score', () {
      final results = DiscoveryEngine.filterRoutes(
        source: mockRoutes,
        searchQuery: '',
        minSafetyFilter: 90,
      );
      expect(results.length, 1);
      expect(results.first.name, 'Safe Park Walk');
    });

    test('filterRoutes should handle combined search and safety filters', () {
      final results = DiscoveryEngine.filterRoutes(
        source: mockRoutes,
        searchQuery: 'Safe',
        minSafetyFilter: 90,
      );
      expect(results.length, 1);
      expect(results.first.name, 'Safe Park Walk');

      final results2 = DiscoveryEngine.filterRoutes(
        source: mockRoutes,
        searchQuery: 'Safe',
        minSafetyFilter: 98,
      );
      expect(results2.length, 0);
    });

    test('sortRoutes should sort by safety', () {
      final results = DiscoveryEngine.sortRoutes(
        routes: mockRoutes,
        selectedCategory: 'safe',
      );
      expect(results[0].safety, 95);
      expect(results[1].safety, 88);
      expect(results[2].safety, 65);
    });

    test('sortRoutes should sort by rating', () {
      final results = DiscoveryEngine.sortRoutes(
        routes: mockRoutes,
        selectedCategory: 'top',
      );
      expect(results[0].rating, 4.8);
      expect(results[1].rating, 4.5);
      expect(results[2].rating, 3.2);
    });

    test('sortRoutes should sort by distance (KM vs M)', () {
      final results = DiscoveryEngine.sortRoutes(
        routes: mockRoutes,
        selectedCategory: 'nearby',
      );
      // 500m (0.5km) < 2.5km < 5km
      expect(results[0].distance, '500 m');
      expect(results[1].distance, '2.5 km');
      expect(results[2].distance, '5 km');
    });

    test('sortRoutes should sort by reviews for trending', () {
      final results = DiscoveryEngine.sortRoutes(
        routes: mockRoutes,
        selectedCategory: 'trending',
      );
      expect(results[0].reviews, 120);
      expect(results[1].reviews, 80);
      expect(results[2].reviews, 45);
    });
  });
}
