import 'package:flutter_test/flutter_test.dart';
import 'package:safestride_app/models/route_model.dart';
import 'package:safestride_app/services/safety_checklist_service.dart';

void main() {
  group('SafetyChecklistService Tests', () {
    final runnerRoute = RouteModel(
      id: 1,
      name: 'Morning Run',
      category: 'Runner',
      distance: '5.0 km',
      safety: 90,
      lighting: 'Poor',
      traffic: 'Low',
      crowd: 'Moderate',
      reviews: 20,
      rating: 4.5,
      image: 'img',
      emoji: '🏃',
    );

    final cyclistRoute = RouteModel(
      id: 2,
      name: 'Cycling Path',
      category: 'Cyclist',
      distance: '10.0 km',
      safety: 85,
      lighting: 'Good',
      traffic: 'High',
      crowd: 'Low',
      reviews: 15,
      rating: 4.2,
      image: 'img',
      emoji: '🚴',
    );

    test('Should provide essential items for all routes', () {
      final checklist = SafetyChecklistService.getChecklist(runnerRoute);
      expect(checklist, contains('Charge your phone to 100%.'));
      expect(checklist, contains('Share your live location with a trusted contact.'));
    });

    test('Should provide runner-specific items', () {
      final checklist = SafetyChecklistService.getChecklist(runnerRoute);
      expect(checklist, contains('Wear reflective gear or high-visibility clothing.'));
      expect(checklist, contains('Carry a personal safety alarm or whistle.'));
    });

    test('Should provide cyclist-specific items', () {
      final checklist = SafetyChecklistService.getChecklist(cyclistRoute);
      expect(checklist, contains('Check tire pressure and brakes.'));
      expect(checklist, contains('Wear a properly fitted helmet.'));
    });

    test('Should include environmental items for poor lighting', () {
      final checklist = SafetyChecklistService.getChecklist(runnerRoute);
      expect(checklist, contains('Bring a headlamp or high-power flashlight.'));
    });

    test('Should include environmental items for high traffic', () {
      final checklist = SafetyChecklistService.getChecklist(cyclistRoute);
      expect(checklist, contains('Stay extra alert at all street crossings.'));
    });

    test('Should provide a categorized checklist', () {
      final categorized = SafetyChecklistService.getCategorizedChecklist(runnerRoute);
      expect(categorized['Essentials']?.length, equals(2));
      expect(categorized['Activity Specific']?.isNotEmpty, isTrue);
      expect(categorized['Environmental Prep']?.isNotEmpty, isTrue);
    });
  });
}
