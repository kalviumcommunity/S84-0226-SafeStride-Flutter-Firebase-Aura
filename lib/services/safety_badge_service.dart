import '../models/route_model.dart';

/// A service that awards achievement badges to [RouteModel] objects based on 
/// their safety metrics and community feedback.
class SafetyBadgeService {
  /// Awards a list of [SafetyBadge] to a given route.
  static List<SafetyBadge> getBadges(RouteModel route) {
    final badges = <SafetyBadge>[];

    // Safety Star: Awarded for extremely high safety scores
    if (route.safety >= 95) {
      badges.add(SafetyBadge(
        name: 'Safety Star',
        description: 'Among the safest routes in the community.',
        icon: '🛡️',
      ));
    }

    // Community Favorite: Awarded for high ratings and many reviews
    if (route.rating >= 4.7 && route.reviews >= 100) {
      badges.add(SafetyBadge(
        name: 'Community Favorite',
        description: 'Highly rated and frequently used by the community.',
        icon: '💖',
      ));
    }

    // Night Owl: Awarded for excellent lighting (ideal for evening activities)
    final lighting = route.lighting.toLowerCase();
    if (lighting.contains('excellent') || lighting.contains('bright')) {
      badges.add(SafetyBadge(
        name: 'Night Owl',
        description: 'Excellent lighting makes this ideal for night use.',
        icon: '🦉',
      ));
    }

    // Quiet Path: Awarded for low traffic
    final traffic = route.traffic.toLowerCase();
    if (traffic.contains('very low') || traffic.contains('none')) {
      badges.add(SafetyBadge(
        name: 'Quiet Path',
        description: 'Minimal traffic for a peaceful experience.',
        icon: '🌿',
      ));
    }

    // Busy & Safe: Awarded for high crowd levels but high safety
    final crowd = route.crowd.toLowerCase();
    if (crowd.contains('high') && route.safety >= 90) {
      badges.add(SafetyBadge(
        name: 'Safe & Social',
        description: 'Popular route with many "eyes on the street".',
        icon: '👥',
      ));
    }

    return badges;
  }

  /// Returns a primary badge (the most significant achievement).
  static SafetyBadge? getPrimaryBadge(RouteModel route) {
    final badges = getBadges(route);
    if (badges.isEmpty) return null;
    
    // Priority order for primary badge
    if (badges.any((b) => b.name == 'Safety Star')) return badges.firstWhere((b) => b.name == 'Safety Star');
    if (badges.any((b) => b.name == 'Community Favorite')) return badges.firstWhere((b) => b.name == 'Community Favorite');
    return badges.first;
  }
}

/// Represents an achievement badge for a route.
class SafetyBadge {
  final String name;
  final String description;
  final String icon;

  SafetyBadge({
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  String toString() => '$icon $name: $description';
}
