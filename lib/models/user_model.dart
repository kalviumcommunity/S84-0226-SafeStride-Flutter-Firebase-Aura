/// Represents a SafeStride user profile stored in Firestore `users` collection.
class UserModel {
  final String uid;
  final String email;
  final String displayName;

  /// 'runner' or 'cyclist'
  final String activityType;

  /// Profile bio / tagline
  final String bio;

  /// Whether the user prefers dark mode
  final bool darkMode;

  /// Whether push notifications are enabled
  final bool notificationsEnabled;

  /// Preferred max route distance in km
  final double preferredDistance;

  /// Number of routes the user has saved
  final int savedRoutesCount;

  /// Number of reviews the user has written
  final int reviewsCount;

  /// Number of favorite routes
  final int favoritesCount;

  /// Total distance covered in km
  final double totalDistanceKm;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.activityType = 'runner',
    this.bio = '',
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.preferredDistance = 10.0,
    this.savedRoutesCount = 0,
    this.reviewsCount = 0,
    this.favoritesCount = 0,
    this.totalDistanceKm = 0.0,
  });

  /// Construct from a Firestore document map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      activityType: map['activityType'] as String? ?? 'runner',
      bio: map['bio'] as String? ?? '',
      darkMode: map['darkMode'] as bool? ?? false,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      preferredDistance: (map['preferredDistance'] as num?)?.toDouble() ?? 10.0,
      savedRoutesCount: map['savedRoutesCount'] as int? ?? 0,
      reviewsCount: map['reviewsCount'] as int? ?? 0,
      favoritesCount: map['favoritesCount'] as int? ?? 0,
      totalDistanceKm: (map['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to a Firestore-friendly map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'activityType': activityType,
      'bio': bio,
      'darkMode': darkMode,
      'notificationsEnabled': notificationsEnabled,
      'preferredDistance': preferredDistance,
      'savedRoutesCount': savedRoutesCount,
      'reviewsCount': reviewsCount,
      'favoritesCount': favoritesCount,
      'totalDistanceKm': totalDistanceKm,
    };
  }

  /// Returns a copy with the specified fields overridden.
  UserModel copyWith({
    String? displayName,
    String? activityType,
    String? bio,
    bool? darkMode,
    bool? notificationsEnabled,
    double? preferredDistance,
    int? savedRoutesCount,
    int? reviewsCount,
    int? favoritesCount,
    double? totalDistanceKm,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      activityType: activityType ?? this.activityType,
      bio: bio ?? this.bio,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferredDistance: preferredDistance ?? this.preferredDistance,
      savedRoutesCount: savedRoutesCount ?? this.savedRoutesCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
    );
  }
}
