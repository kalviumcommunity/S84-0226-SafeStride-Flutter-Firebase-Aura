import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/location_service.dart';
import '../services/routing_service.dart';

/// Manages all state for an active turn-by-turn navigation session.
///
/// Responsibilities:
///   - Fetching the initial route from OSRM via [RoutingService].
///   - Streaming live GPS updates using [Geolocator.getPositionStream].
///   - Updating [userPosition] and notifying listeners on every GPS fix.
///   - Auto-rerouting when the user drifts more than [offRouteThresholdMetres]
///     from the current route polyline.
///
/// Extend with [ChangeNotifier] so any widget can rebuild via [addListener].
///
/// Usage:
/// ```dart
/// final controller = NavigationController(
///   destination: LatLng(37.8044, -122.2712),
///   destinationName: 'Redwood Trail',
///   profile: RoutingProfile.foot,
/// );
/// controller.addListener(() => setState(() {}));
/// await controller.start();
/// ```
class NavigationController extends ChangeNotifier {
  NavigationController({
    required this.destination,
    required this.destinationName,
    required this.profile,
    RoutingService? routingService,
  }) : _routingService = routingService ?? RoutingService();

  // ── Configuration ──────────────────────────────────────────────────────────

  /// The destination coordinates the user is navigating towards.
  final LatLng destination;

  /// Display name shown on the destination marker.
  final String destinationName;

  /// OSRM transport profile (foot or bike).
  final RoutingProfile profile;

  /// Distance in metres beyond which an automatic reroute is triggered.
  static const double offRouteThresholdMetres = 50.0;

  // ── Dependencies ───────────────────────────────────────────────────────────

  final RoutingService _routingService;
  StreamSubscription<Position>? _positionSub;

  // ── Public state ───────────────────────────────────────────────────────────

  /// Ordered list of [LatLng] points defining the current route polyline.
  List<LatLng> routePoints = const [];

  /// Latest known user position. `null` until the first GPS fix arrives.
  LatLng? userPosition;

  /// `true` while the initial route is being fetched.
  bool isLoading = true;

  /// `true` while a reroute request is in flight.
  bool isRerouting = false;

  /// Non-null when a terminal error has occurred (e.g. no GPS permission,
  /// OSRM unreachable). The UI should display this message to the user.
  String? errorMessage;

  /// Human-readable route distance, e.g. `"1.4 km"` or `"350 m"`.
  String routeDistance = '';

  /// Human-readable ETA, e.g. `"~17 min"`.
  String routeEta = '';

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Starts the navigation session:
  ///   1. Obtains the current GPS position.
  ///   2. Fetches the initial route from OSRM.
  ///   3. Begins streaming real-time location updates.
  Future<void> start() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // Step 1: obtain current position.
    final Position startPos;
    try {
      startPos = await LocationService.getCurrentLocation();
    } on LocationServiceException catch (e) {
      isLoading = false;
      errorMessage = e.message;
      notifyListeners();
      return;
    }

    userPosition = LatLng(startPos.latitude, startPos.longitude);

    // Step 2: fetch the initial route to the destination.
    await _fetchRoute(userPosition!);

    // Step 3: subscribe to live position updates.
    _startPositionStream();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Calls OSRM to retrieve a route from [from] to [destination] and updates
  /// [routePoints], [routeDistance], [routeEta], and [errorMessage].
  Future<void> _fetchRoute(LatLng from) async {
    try {
      final result = await _routingService.getRoute(
        startLat: from.latitude,
        startLng: from.longitude,
        endLat: destination.latitude,
        endLng: destination.longitude,
        profile: profile,
      );

      routePoints = result.points;
      isLoading = false;
      isRerouting = false;
      errorMessage = null;

      // Format distance for display.
      final km = result.distanceMetres / 1000;
      routeDistance = km >= 1
          ? '${km.toStringAsFixed(1)} km'
          : '${result.distanceMetres.round()} m';

      // Format ETA (OSRM provides duration in seconds).
      final minutes = (result.durationSeconds / 60).round();
      routeEta = '~$minutes min';
    } on RoutingException catch (e) {
      isLoading = false;
      isRerouting = false;
      errorMessage = 'Could not load route: ${e.message}';
    }

    notifyListeners();
  }

  /// Subscribes to [Geolocator.getPositionStream] for continuous GPS updates.
  /// Uses a 5-metre distance filter to reduce unnecessary rebuilds.
  void _startPositionStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(_onPositionUpdate);
  }

  /// Called on every new GPS fix.
  ///
  /// Updates [userPosition] and triggers rerouting if the user has drifted
  /// more than [offRouteThresholdMetres] from the known route.
  void _onPositionUpdate(Position position) {
    userPosition = LatLng(position.latitude, position.longitude);
    notifyListeners();

    // Only check off-route when we have a valid polyline and are not already
    // waiting for a reroute response.
    if (routePoints.isNotEmpty && !isRerouting && !isLoading) {
      final dist = _minDistanceToPolyline(userPosition!, routePoints);
      if (dist > offRouteThresholdMetres) {
        _reroute();
      }
    }
  }

  /// Triggers a new OSRM request from the current user position.
  Future<void> _reroute() async {
    if (userPosition == null) return;
    isRerouting = true;
    notifyListeners();
    await _fetchRoute(userPosition!);
  }

  // ── Geometry helpers ───────────────────────────────────────────────────────

  /// Returns the shortest distance (metres) from [point] to any segment of
  /// the [polyline], using a flat-earth Cartesian projection.
  ///
  /// Accuracy is sufficient for the < 50 m threshold used for rerouting.
  double _minDistanceToPolyline(LatLng point, List<LatLng> polyline) {
    if (polyline.isEmpty) return double.infinity;
    if (polyline.length == 1) {
      return Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        polyline.first.latitude,
        polyline.first.longitude,
      );
    }

    double minDist = double.infinity;
    for (int i = 0; i < polyline.length - 1; i++) {
      final d = _distanceToSegment(point, polyline[i], polyline[i + 1]);
      if (d < minDist) minDist = d;
    }
    return minDist;
  }

  /// Approximates the perpendicular distance (metres) from [p] to the line
  /// segment [a]–[b] using a local flat-earth Cartesian projection.
  double _distanceToSegment(LatLng p, LatLng a, LatLng b) {
    const toRad = math.pi / 180;
    const earthRadius = 6371000.0; // metres

    // Project all three points into a 2-D Cartesian frame centred at `a`.
    // cos(lat) compensates for longitude shrinkage away from the equator.
    final cosLat = math.cos(a.latitude * toRad);

    double toX(double lon) => lon * cosLat * toRad * earthRadius;
    double toY(double lat) => lat * toRad * earthRadius;

    final ax = toX(a.longitude), ay = toY(a.latitude);
    final bx = toX(b.longitude), by = toY(b.latitude);
    final px = toX(p.longitude), py = toY(p.latitude);

    final dx = bx - ax, dy = by - ay;
    final len2 = dx * dx + dy * dy;

    if (len2 == 0) {
      // Degenerate segment (a == b) — return distance to the point itself.
      final ex = px - ax, ey = py - ay;
      return math.sqrt(ex * ex + ey * ey);
    }

    // Project p onto [a, b] and clamp to the segment bounds [0, 1].
    final t = ((px - ax) * dx + (py - ay) * dy) / len2;
    final tClamped = t.clamp(0.0, 1.0);

    final closestX = ax + tClamped * dx;
    final closestY = ay + tClamped * dy;

    final ex = px - closestX, ey = py - closestY;
    return math.sqrt(ex * ex + ey * ey);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}
