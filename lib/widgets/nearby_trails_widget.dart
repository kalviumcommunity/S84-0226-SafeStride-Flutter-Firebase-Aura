import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/place.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

/// Demonstrates fetching nearby parks and trails by combining
/// [LocationService] and [PlacesService].
///
/// Replace [_apiKey] with a real Google Places API key before running.
/// For production apps store keys in a secure backend or via
/// `--dart-define` / a secrets manager — never hard-code them.
class NearbyTrailsWidget extends StatefulWidget {
  const NearbyTrailsWidget({super.key});

  @override
  State<NearbyTrailsWidget> createState() => _NearbyTrailsWidgetState();
}

class _NearbyTrailsWidgetState extends State<NearbyTrailsWidget> {
  final _placesService = PlacesService();

  List<Place> _places = const [];
  bool _loading = false;
  String? _errorMessage;

  // ── Fetch flow ─────────────────────────────────────────────────────────────

  Future<void> _loadNearbyTrails() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _places = const [];
    });

    try {
      // Step 1 – obtain the user's current GPS position.
      final Position position = await LocationService.getCurrentLocation();

      debugPrint(
        '[NearbyTrailsWidget] User location → '
        '${position.latitude}, ${position.longitude}',
      );

      // Step 2 – query the Places API with that position.
      final List<Place> places = await _placesService.getNearbyTrails(
        position.latitude,
        position.longitude,
      );

      // Step 3 – print each result to the debug console.
      if (places.isEmpty) {
        debugPrint('[NearbyTrailsWidget] No nearby trails found.');
      } else {
        debugPrint(
          '[NearbyTrailsWidget] Found ${places.length} nearby trail(s):',
        );
        for (final place in places) {
          debugPrint('  $place');
        }
      }

      if (mounted) setState(() => _places = places);
    } on LocationServiceException catch (e) {
      debugPrint('[NearbyTrailsWidget] Location error: $e');
      _handleLocationError(e);
    } on PlacesNetworkException catch (e) {
      debugPrint('[NearbyTrailsWidget] Network error: $e');
      if (mounted) {
        setState(
          () => _errorMessage =
              'Network error. Please check your internet connection.',
        );
      }
    } on PlacesException catch (e) {
      debugPrint('[NearbyTrailsWidget] Places error: $e');
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      debugPrint('[NearbyTrailsWidget] Unexpected error: $e');
      if (mounted) {
        setState(() => _errorMessage = 'An unexpected error occurred: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleLocationError(LocationServiceException e) {
    if (!mounted) return;

    if (e.error == LocationServiceError.permissionDeniedForever) {
      _showActionDialog(
        title: 'Permission Required',
        content:
            'Location permission is permanently denied. Open app settings to grant it.',
        actionLabel: 'Open Settings',
        onAction: LocationService.openAppSettings,
      );
    } else if (e.error == LocationServiceError.servicesDisabled) {
      _showActionDialog(
        title: 'Location Services Off',
        content:
            'Location services are disabled. Enable them to find nearby trails.',
        actionLabel: 'Open Settings',
        onAction: LocationService.openLocationSettings,
      );
    } else {
      setState(() => _errorMessage = e.message);
    }
  }

  void _showActionDialog({
    required String title,
    required String content,
    required String actionLabel,
    required Future<bool> Function() onAction,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onAction();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Parks & Trails')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _loading ? null : _loadNearbyTrails,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.forest_outlined),
              label: Text(_loading ? 'Searching…' : 'Find Nearby Trails'),
            ),
            const SizedBox(height: 12),
            if (_errorMessage != null) _ErrorBanner(message: _errorMessage!),
            if (_places.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: _places.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) => _PlaceCard(place: _places[index]),
                ),
              ),
            if (!_loading && _places.isEmpty && _errorMessage == null)
              const _EmptyState(),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.park_outlined, size: 32),
        title: Text(
          place.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (place.address != null)
              Text(
                place.address!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 2),
            Text(
              'Lat: ${place.latitude.toStringAsFixed(5)}  '
              'Lng: ${place.longitude.toStringAsFixed(5)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        trailing: place.rating != null
            ? _RatingBadge(rating: place.rating!)
            : null,
        isThreeLine: true,
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.forest_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the button to discover\nnearby parks and trails.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
