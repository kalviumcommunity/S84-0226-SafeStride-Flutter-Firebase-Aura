import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/place.dart';

// ── Custom exceptions ─────────────────────────────────────────────────────────

/// Base class for all errors raised by [PlacesService].
sealed class PlacesException implements Exception {
  const PlacesException(this.message);
  final String message;

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

/// The HTTP request itself failed (no connectivity, DNS failure, timeout, etc.).
final class PlacesNetworkException extends PlacesException {
  const PlacesNetworkException(super.message);
}

/// The server returned a non-200 HTTP status code.
final class PlacesHttpException extends PlacesException {
  const PlacesHttpException(super.message, this.statusCode);
  final int statusCode;
}

/// Returned when the API response payload cannot be parsed.
final class PlacesParseException extends PlacesException {
  const PlacesParseException(super.message);
}

// ── PlacesService ─────────────────────────────────────────────────────────────

/// Fetches nearby parks, trails, and walking paths using the
/// **OpenStreetMap Overpass API** — completely free, no API key required,
/// and CORS-enabled so it works in Flutter Web browsers.
///
/// Data source: https://overpass-api.de/api/interpreter
///
/// Usage:
/// ```dart
/// final service = PlacesService();
/// final places = await service.getNearbyTrails(37.7749, -122.4194);
/// ```
class PlacesService {
  PlacesService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Overpass interpreter endpoints (public mirrors).
  ///
  /// We try these sequentially so temporary outages (HTTP 502/503/504/429)
  /// on one host do not break nearby-trail discovery.
  static const List<String> _baseUrls = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
  ];

  /// Default search radius in metres (10 km).
  static const int _defaultRadiusMetres = 10000;

  /// Fallback search radius used on automatic retry (20 km).
  static const int _fallbackRadiusMetres = 20000;

  /// Builds an Overpass QL query string for the given [radius], [lat], [lng].
  ///
  /// Searches for:
  ///   • leisure=park      — public parks
  ///   • route=hiking      — named hiking routes
  ///   • highway=path      — unsurfaced paths
  ///   • highway=footway   — pedestrian footways
  String _buildQuery(int radius, double lat, double lng) =>
      '''
[out:json][timeout:30];
(
  node["leisure"="park"](around:$radius,$lat,$lng);
  way["leisure"="park"](around:$radius,$lat,$lng);

  node["route"="hiking"](around:$radius,$lat,$lng);
  way["route"="hiking"](around:$radius,$lat,$lng);

  node["highway"="path"](around:$radius,$lat,$lng);
  way["highway"="path"](around:$radius,$lat,$lng);

  node["highway"="footway"](around:$radius,$lat,$lng);
  way["highway"="footway"](around:$radius,$lat,$lng);
);
out center;
''';

  /// Returns a list of [Place] objects (parks, trails, footways) near [lat]/[lng].
  ///
  /// Search strategy:
  ///   1. Query within **10 km** first.
  ///   2. If zero named results are found, automatically retry at **20 km**.
  ///
  /// Throws:
  ///   - [PlacesNetworkException] on connectivity / timeout failures.
  ///   - [PlacesHttpException] on non-200 HTTP responses.
  ///   - [PlacesParseException] on malformed response payloads.
  Future<List<Place>> getNearbyTrails(double lat, double lng) async {
    // First attempt at the default 10 km radius.
    var results = await _query(lat, lng, _defaultRadiusMetres);

    // Auto-retry at 20 km if nothing was returned.
    if (results.isEmpty) {
      print('[PlacesService] No results within 10 km — retrying at 20 km...');
      results = await _query(lat, lng, _fallbackRadiusMetres);
    }

    print('[PlacesService] Returning ${results.length} place(s) to UI.');
    return results;
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Executes one Overpass request for [radius] metres around [lat]/[lng]
  /// and returns parsed, deduplicated [Place] objects.
  Future<List<Place>> _query(double lat, double lng, int radius) async {
    final query = _buildQuery(radius, lat, lng);

    PlacesException? lastRecoverableError;

    for (final baseUrl in _baseUrls) {
      final http.Response response;

      // ── Network request ─────────────────────────────────────────────────
      try {
        response = await _client
            .post(
              Uri.parse(baseUrl),
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              body: 'data=${Uri.encodeComponent(query)}',
            )
            .timeout(const Duration(seconds: 35));
      } on Exception catch (e) {
        lastRecoverableError = PlacesNetworkException(
          'Network request failed for $baseUrl: $e',
        );
        continue;
      }

      // ── HTTP status ─────────────────────────────────────────────────────
      if (response.statusCode != 200) {
        // Recoverable overload / gateway statuses → try next mirror.
        if (response.statusCode == 429 ||
            response.statusCode == 502 ||
            response.statusCode == 503 ||
            response.statusCode == 504) {
          lastRecoverableError = PlacesHttpException(
            'Overpass mirror $baseUrl returned HTTP ${response.statusCode}.',
            response.statusCode,
          );
          continue;
        }

        // Non-recoverable client errors should fail fast.
        throw PlacesHttpException(
          'Overpass API returned HTTP ${response.statusCode}.',
          response.statusCode,
        );
      }

      // ── JSON decoding ───────────────────────────────────────────────────
      final Map<String, dynamic> body;
      try {
        body = json.decode(response.body) as Map<String, dynamic>;
      } on FormatException catch (e) {
        throw PlacesParseException('Invalid JSON from Overpass API: $e');
      }

      // ── Debug: log raw element count ────────────────────────────────────
      final rawElements = body['elements'] as List<dynamic>? ?? const [];
      print('Overpass elements returned: ${rawElements.length}');

      if (rawElements.isEmpty) return const [];

      // ── Parse & deduplicate by coordinates ─────────────────────────────
      final seen = <String>{};
      final places = <Place>[];

      for (final item in rawElements) {
        try {
          final place = Place.fromOverpassJson(item as Map<String, dynamic>);
          final key =
              '${place.latitude.toStringAsFixed(4)}_${place.longitude.toStringAsFixed(4)}';
          if (seen.add(key)) places.add(place);
        } on FormatException {
          continue;
        }
      }

      print('Trails after filtering: ${places.length}');
      return places;
    }

    if (lastRecoverableError != null) throw lastRecoverableError;
    throw const PlacesNetworkException(
      'All Overpass API mirrors are temporarily unavailable.',
    );
  }
}
