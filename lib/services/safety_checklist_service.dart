import '../models/route_model.dart';

/// A service that provides activity-specific safety checklists for users
/// before they begin a route.
class SafetyChecklistService {
  /// Returns a list of safety checklist items based on the route's category.
  static List<String> getChecklist(RouteModel route) {
    final items = <String>[];
    
    // Global items
    items.add('Charge your phone to 100%.');
    items.add('Share your live location with a trusted contact.');
    
    final category = route.category.toLowerCase();
    
    if (category.contains('runner')) {
      items.addAll([
        'Wear reflective gear or high-visibility clothing.',
        'Carry a personal safety alarm or whistle.',
        'Ensure your running shoes are securely tied.',
      ]);
    } else if (category.contains('cyclist')) {
      items.addAll([
        'Check tire pressure and brakes.',
        'Wear a properly fitted helmet.',
        'Ensure front and rear lights are functioning.',
      ]);
    } else if (category.contains('walk')) {
      items.addAll([
        'Wear comfortable walking shoes.',
        'Stay on designated pedestrian paths.',
      ]);
    }

    // Environmental items
    final lighting = route.lighting.toLowerCase();
    if (lighting.contains('poor') || lighting.contains('dark')) {
      items.add('Bring a headlamp or high-power flashlight.');
    }
    
    final traffic = route.traffic.toLowerCase();
    if (traffic.contains('high')) {
      items.add('Stay extra alert at all street crossings.');
    }

    return items;
  }

  /// Categorizes checklist items for better UI presentation.
  static Map<String, List<String>> getCategorizedChecklist(RouteModel route) {
    final checklist = getChecklist(route);
    return {
      'Essentials': checklist.where((i) => i.contains('phone') || i.contains('location')).toList(),
      'Activity Specific': checklist.where((i) => !i.contains('phone') && !i.contains('location') && !i.contains('headlamp') && !i.contains('crossings')).toList(),
      'Environmental Prep': checklist.where((i) => i.contains('headlamp') || i.contains('crossings')).toList(),
    };
  }
}
