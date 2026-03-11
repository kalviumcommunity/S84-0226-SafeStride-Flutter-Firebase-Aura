/// Represents a single place returned by the Google Places Nearby Search API.
///
/// Only the fields relevant to trail / park discovery are mapped here.
/// All nullable fields reflect real-world API responses where data can be
/// absent (e.g. a place with no user ratings yet).
class Place {
  /// The display name of the place (e.g. "Yellowstone National Park").
  final String name;

  /// WGS-84 latitude of the place's geometry centre.
  final double latitude;

  /// WGS-84 longitude of the place's geometry centre.
  final double longitude;

  /// Average user rating in the range [1.0, 5.0]. `null` if not yet rated.
  final double? rating;

  /// Human-readable address (vicinity field from the Places API).
  /// `null` when the API omits it.
  final String? address;

  const Place({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.address,
  });

  /// Constructs a [Place] from a single JSON object inside the `results` array
  /// of a legacy Nearby Search response.
  ///
  /// Throws a [FormatException] if mandatory fields (`name`, `geometry`) are
  /// absent, allowing [PlacesService] to filter out malformed entries.
  factory Place.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;

    if (json['name'] == null || location == null) {
      throw const FormatException('Missing required fields: name or geometry');
    }

    return Place(
      name: json['name'] as String,
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      address: json['vicinity'] as String?,
    );
  }

  /// Constructs a [Place] from a single element in the Overpass API response.
  ///
  /// Constructs a [Place] from a single element in the Overpass API response.
  ///
  /// Supports both:
  ///   • `node` elements — carry `lat`/`lon` directly.
  ///   • `way`/`relation` elements — carry coordinates in a `center` object.
  ///
  /// When the OSM `name` tag is absent a fallback display name is derived
  /// from other available tags so that unnamed paths/footways are still shown.
  /// Only elements with no resolvable coordinates are discarded.
  factory Place.fromOverpassJson(Map<String, dynamic> json) {
    final tags = json['tags'] as Map<String, dynamic>? ?? const {};

    // Prefer the OSM name tag; fall back to other descriptive tags.
    final name = (tags['name'] as String?)?.trim().isNotEmpty == true
        ? tags['name'] as String
        : (tags['leisure'] as String?) ??
              (tags['highway'] as String?) ??
              (tags['route'] as String?) ??
              'Walking Trail';

    // Nodes carry lat/lon directly; ways/relations provide a `center` object.
    double? lat, lng;
    if (json['type'] == 'node') {
      lat = (json['lat'] as num?)?.toDouble();
      lng = (json['lon'] as num?)?.toDouble();
    } else {
      final center = json['center'] as Map<String, dynamic>?;
      lat = (center?['lat'] as num?)?.toDouble();
      lng = (center?['lon'] as num?)?.toDouble();
    }

    if (lat == null || lng == null) {
      throw const FormatException('Missing coordinates in OSM element');
    }

    // OSM has no star rating. Use `stars` tag when present (rare), otherwise null.
    final starsTag = tags['stars'] as String?;
    final rating = starsTag != null ? double.tryParse(starsTag) : null;

    // Build a readable address from available OSM address tags.
    final street = tags['addr:street'] as String?;
    final city = tags['addr:city'] as String?;
    final address = [street, city].whereType<String>().join(', ');

    return Place(
      name: name,
      latitude: lat,
      longitude: lng,
      rating: rating,
      address: address.isEmpty ? null : address,
    );
  }

  /// Constructs a [Place] from a single entry in the `places` array returned
  /// by the **Places API (New)** (`places.googleapis.com/v1/places:searchNearby`).
  /// Kept for reference; not used when the Overpass backend is active.
  factory Place.fromNewApiJson(Map<String, dynamic> json) {
    final displayName = json['displayName'] as Map<String, dynamic>?;
    final location = json['location'] as Map<String, dynamic>?;
    final name = displayName?['text'] as String?;

    if (name == null || location == null) {
      throw const FormatException(
        'Missing required fields: displayName or location',
      );
    }

    return Place(
      name: name,
      latitude: (location['latitude'] as num).toDouble(),
      longitude: (location['longitude'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      address: json['shortFormattedAddress'] as String?,
    );
  }

  /// Serialises this [Place] back to a JSON-compatible map (useful for caching
  /// or passing to Firestore later).
  Map<String, dynamic> toJson() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    if (rating != null) 'rating': rating,
    if (address != null) 'address': address,
  };

  @override
  String toString() =>
      'Place(name: $name, lat: $latitude, lng: $longitude, '
      'rating: ${rating ?? "N/A"}, address: ${address ?? "N/A"})';
}
