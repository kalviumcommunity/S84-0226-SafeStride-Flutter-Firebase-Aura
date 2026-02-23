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
  });
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
