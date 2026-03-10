import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

/// A self-contained widget that demonstrates [LocationService.getCurrentLocation].
///
/// Tapping the button fetches the device's current position and prints the
/// latitude / longitude to the debug console. Any error is displayed inline
/// inside the widget so the user is never left with a blank screen.
class LocationDemoWidget extends StatefulWidget {
  const LocationDemoWidget({super.key});

  @override
  State<LocationDemoWidget> createState() => _LocationDemoWidgetState();
}

class _LocationDemoWidgetState extends State<LocationDemoWidget> {
  Position? _position;
  String? _errorMessage;
  bool _loading = false;

  Future<void> _fetchLocation() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _position = null;
    });

    try {
      final position = await LocationService.getCurrentLocation();

      // Print to debug console as requested.
      debugPrint(
        'Current location → lat: ${position.latitude}, '
        'lng: ${position.longitude}',
      );

      if (mounted) setState(() => _position = position);
    } on LocationServiceException catch (e) {
      debugPrint('Location error (${e.error.name}): ${e.message}');

      // For permanently-denied permission, offer to open settings.
      if (e.error == LocationServiceError.permissionDeniedForever && mounted) {
        _showOpenSettingsDialog();
      }

      // For disabled location services, offer to open location settings.
      if (e.error == LocationServiceError.servicesDisabled && mounted) {
        _showEnableServicesDialog();
      }

      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showOpenSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Location permission is permanently denied. '
          'Open app settings to grant it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              LocationService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showEnableServicesDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Location Services Off'),
        content: const Text(
          'Location services are disabled. '
          'Please enable them in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              LocationService.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _loading ? null : _fetchLocation,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(_loading ? 'Fetching…' : 'Get Current Location'),
          ),
          if (_position != null) ...[
            const SizedBox(height: 16),
            _InfoTile(
              label: 'Latitude',
              value: _position!.latitude.toStringAsFixed(6),
            ),
            _InfoTile(
              label: 'Longitude',
              value: _position!.longitude.toStringAsFixed(6),
            ),
            _InfoTile(
              label: 'Accuracy',
              value: '${_position!.accuracy.toStringAsFixed(1)} m',
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
