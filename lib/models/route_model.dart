class RouteModel {
  final int id;
  final String name;
  final String category;
  final String distance;
  final int safety;
  final String lighting;
  final String traffic;
  final String crowd;
  final int reviews;
  final double rating;
  final String image;
  final String emoji;
  final String? tag;

  /// WGS-84 latitude of the route/trail location.
  /// Set when the route originates from an Overpass API result.
  /// `null` for hardcoded mock routes.
  final double? latitude;

  /// WGS-84 longitude of the route/trail location.
  /// Set when the route originates from an Overpass API result.
  /// `null` for hardcoded mock routes.
  final double? longitude;

  RouteModel({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.safety,
    required this.lighting,
    required this.traffic,
    required this.crowd,
    required this.reviews,
    required this.rating,
    required this.image,
    required this.emoji,
    this.tag,
    this.latitude,
    this.longitude,
  });

  factory RouteModel.fromMap(Map<String, dynamic> map) {
    return RouteModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? 'Unknown Route',
      category: map['category'] as String? ?? 'Mixed',
      distance: map['distance'] as String? ?? '0 km',
      safety: map['safety'] as int? ?? 50,
      lighting: map['lighting'] as String? ?? 'Average',
      traffic: map['traffic'] as String? ?? 'Average',
      crowd: map['crowd'] as String? ?? 'Average',
      reviews: map['reviews'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      image: map['image'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '📍',
      tag: map['tag'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}

class Review {
  final int id;
  final String author;
  final String avatar;
  final int rating;
  final String date;
  final String text;
  final int helpful;

  Review({
    required this.id,
    required this.author,
    required this.avatar,
    required this.rating,
    required this.date,
    required this.text,
    required this.helpful,
  });
}

class AlertModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final String location;
  final String time;
  final String color;

  AlertModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.location,
    required this.time,
    required this.color,
  });
}
