import 'dart:convert';
import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// ── Routing profile ───────────────────────────────────────────────────────────

/// The OSRM transport profile to use when requesting a route.
enum RoutingProfile {
  /// Pedestrian — footpaths, parks, pavements.
  foot,

  /// Cycling — cycle-lanes, roads.
  bike,
}

// ── Result type ───────────────────────────────────────────────────────────────

/// Holds the decoded route returned by [RoutingService.getRoute].
class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMetres,
    required this.durationSeconds,
  });

  /// Ordered list of [LatLng] coordinates that form the route polyline.
  final List<LatLng> points;

  /// Total route length in metres.
  final double distanceMetres;

  /// Estimated travel time in seconds.
  final double durationSeconds;
}

// ── Custom exceptions ─────────────────────────────────────────────────────────

sealed class RoutingException implements Exception {
  const RoutingException(this.message);

  final String message;

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

/// Thrown when the HTTP request itself fails (no network, DNS, timeout, etc.).
final class RoutingNetworkException extends RoutingException {
  const RoutingNetworkException(super.message);
}

/// Thrown when the OSRM server returns a non-200 HTTP status.
final class RoutingHttpException extends RoutingException {
  const RoutingHttpException(super.message, this.statusCode);

  final int statusCode;
}

/// Thrown when OSRM cannot find a route between the two points.
final class RoutingNoRouteException extends RoutingException {
  const RoutingNoRouteException(super.message);
}

// ── RoutingService ────────────────────────────────────────────────────────────

/// Fetches walking and cycling routes using the **OSRM public API**.
///
/// - Completely free, no API key required.
/// - Data from OpenStreetMap.
/// - CORS-enabled — works in Flutter Web.
///
/// Endpoint: https://router.project-osrm.org
///
/// Usage:
/// ```dart
/// final service = RoutingService();
/// final result = await service.getRoute(
///   startLat: 37.7749, startLng: -122.4194,
///   endLat: 37.8044,   endLng: -122.2712,
/// );
/// drawPolyline(result.points);
/// ```
class RoutingService {
  RoutingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://router.project-osrm.org';

  /// Requests a route from ([startLat], [startLng]) to ([endLat], [endLng]).
  ///
  /// [profile] selects the transport mode:
  ///   - [RoutingProfile.foot] → pedestrian routing (default)
  ///   - [RoutingProfile.bike] → cycling routing
  ///
  /// Throws:
  ///   - [RoutingNetworkException] on connectivity / timeout failures.
  ///   - [RoutingHttpException] on non-200 HTTP responses.
  ///   - [RoutingNoRouteException] when OSRM has no path between the points.
  Future<RouteResult> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    RoutingProfile profile = RoutingProfile.foot,
  }) async {
    // OSRM expects coordinates in lng,lat order (longitude first).
    final profileStr = profile == RoutingProfile.foot ? 'foot' : 'bike';
    final uri = Uri.parse(
      '$_baseUrl/route/v1/$profileStr/'
      '$startLng,$startLat;$endLng,$endLat'
      '?overview=full&geometries=geojson',
    );

    // ── HTTP request ──────────────────────────────────────────────────────────
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 20));
    } on Exception catch (e) {
      throw RoutingNetworkException('Network request failed: $e');
    }

    if (response.statusCode != 200) {
      throw RoutingHttpException(
        'OSRM returned HTTP ${response.statusCode}.',
        response.statusCode,
      );
    }

    // ── Parse JSON ────────────────────────────────────────────────────────────
    final Map<String, dynamic> body;
    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw RoutingNetworkException('Invalid JSON from OSRM: $e');
    }

    // OSRM sets `code` to "Ok" on success; any other value means no route.
    final code = body['code'] as String?;
    if (code != 'Ok') {
      throw RoutingNoRouteException(
        'OSRM could not find a route (code: $code).',
      );
    }

    final routes = body['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw const RoutingNoRouteException('No routes in OSRM response.');
    }

    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final distance = (route['distance'] as num).toDouble();
    final duration = (route['duration'] as num).toDouble();

    final points = _parseGeoJsonLineString(geometry);
    if (points.length < 2) {
      throw const RoutingNoRouteException(
        'OSRM returned an invalid route geometry.',
      );
    }

    return RouteResult(
      points: _sanitizePoints(points),
      distanceMetres: distance,
      durationSeconds: duration,
    );
  }

  static List<LatLng> _parseGeoJsonLineString(Map<String, dynamic> geometry) {
    final coordinates = geometry['coordinates'] as List<dynamic>?;
    if (coordinates == null) return const [];

    final points = <LatLng>[];
    for (final item in coordinates) {
      final pair = item as List<dynamic>?;
      if (pair == null || pair.length < 2) continue;

      final lng = (pair[0] as num?)?.toDouble();
      final lat = (pair[1] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      points.add(LatLng(lat, lng));
    }

    return points;
  }

  static List<LatLng> _sanitizePoints(List<LatLng> points) {
    if (points.length < 2) return points;

    final sanitized = <LatLng>[points.first];
    for (int i = 1; i < points.length; i++) {
      final prev = sanitized.last;
      final current = points[i];

      // Drop improbable GPS jumps that create long straight artifact lines.
      // Distance computed in metres using a simple haversine approximation.
      final jump = _distanceMeters(prev, current);
      if (jump <= 800) {
        sanitized.add(current);
      }
    }

    if (sanitized.length < 2) return points;
    return sanitized;
  }

  static double _distanceMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    final dLat = (b.latitude - a.latitude) * (3.141592653589793 / 180.0);
    final dLng = (b.longitude - a.longitude) * (3.141592653589793 / 180.0);
    final lat1 = a.latitude * (3.141592653589793 / 180.0);
    final lat2 = b.latitude * (3.141592653589793 / 180.0);

    final sinDLat = math.sin(dLat / 2);
    final sinDLng = math.sin(dLng / 2);
    final h =
        sinDLat * sinDLat + sinDLng * sinDLng * math.cos(lat1) * math.cos(lat2);
    return 2 * earthRadius * math.asin(math.sqrt(h));
  }

  // ── Polyline decoder ──────────────────────────────────────────────────────

  /// Decodes a Google-encoded polyline string into ordered [LatLng] points.
  ///
  /// OSRM uses the same encoding as the Google Maps Encoded Polyline Algorithm:
  /// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  static List<LatLng> decodePolyline(String encoded) =>
      _decodePolyline(encoded);

  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      // ── Decode latitude delta ───────────────────────────────────────────
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      // ── Decode longitude delta ──────────────────────────────────────────
      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
