import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../constants/app_colors.dart';

class LocationStep extends StatefulWidget {
  final bool isDarkMode;
  final List<LatLng> routePoints;
  final ValueChanged<List<LatLng>> onRoutePointsChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const LocationStep({
    super.key,
    required this.isDarkMode,
    required this.routePoints,
    required this.onRoutePointsChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  static const LatLng _defaultCenter = LatLng(14.5995, 120.9842);

  GoogleMapController? _mapController;
  bool _mapVisible = false;
  bool _mapInitialized = false;
  bool _mapLoadTimedOut = false;
  Timer? _mapLoadTimer;

  Set<Marker> get _markers {
    return widget.routePoints.asMap().entries.map((entry) {
      final int index = entry.key;
      final LatLng point = entry.value;
      final bool isStart = index == 0;

      return Marker(
        markerId: MarkerId('route_point_$index'),
        position: point,
        infoWindow: InfoWindow(
          title: isStart ? 'Start Point' : 'Route Point ${index + 1}',
        ),
      );
    }).toSet();
  }

  Set<Polyline> get _polylines {
    if (widget.routePoints.length < 2) {
      return <Polyline>{};
    }

    return <Polyline>{
      Polyline(
        polylineId: const PolylineId('custom_route_polyline'),
        points: widget.routePoints,
        color: AppColors.primaryBlue,
        width: 5,
        geodesic: true,
      ),
    };
  }

  void _handleMapTap(LatLng point) {
    debugPrint(
      '[LocationStep] Map tap captured at (${point.latitude}, ${point.longitude})',
    );
    // Append new tap point and bubble updated route back to the parent page.
    final List<LatLng> updated = List<LatLng>.from(widget.routePoints)
      ..add(point);
    widget.onRoutePointsChanged(updated);
  }

  void _openMap() {
    setState(() {
      _mapVisible = true;
      _mapLoadTimedOut = false;
      _mapInitialized = false;
    });

    _mapLoadTimer?.cancel();
    _mapLoadTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || _mapInitialized) return;
      setState(() {
        _mapLoadTimedOut = true;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _fitCameraToRoute());
  }

  void _undoLastPoint() {
    if (widget.routePoints.isEmpty) {
      return;
    }

    final List<LatLng> updated = List<LatLng>.from(widget.routePoints)
      ..removeLast();
    widget.onRoutePointsChanged(updated);
  }

  void _clearRoute() {
    if (widget.routePoints.isEmpty) {
      return;
    }

    widget.onRoutePointsChanged(<LatLng>[]);
  }

  Future<void> _fitCameraToRoute() async {
    if (_mapController == null || widget.routePoints.isEmpty) {
      return;
    }

    if (widget.routePoints.length == 1) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(widget.routePoints.first, 16),
      );
      return;
    }

    double minLat = widget.routePoints.first.latitude;
    double maxLat = widget.routePoints.first.latitude;
    double minLng = widget.routePoints.first.longitude;
    double maxLng = widget.routePoints.first.longitude;

    for (final LatLng point in widget.routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 64),
    );
  }

  @override
  void didUpdateWidget(covariant LocationStep oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.routePoints.length != widget.routePoints.length &&
        _mapVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitCameraToRoute());
    }
  }

  @override
  void dispose() {
    _mapLoadTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasRoute = widget.routePoints.isNotEmpty;
    debugPrint(
      '[LocationStep] build | visible=$_mapVisible | points=${widget.routePoints.length}',
    );

    return Column(
      // Use min height inside scrollables to avoid unbounded-height layout issues.
      mainAxisSize: MainAxisSize.min,
      // Stretch children so cards/map receive full available width consistently.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: widget.isDarkMode ? 0.18 : 0.08,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Mark Your Route',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap on the map to mark the starting point and route path',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openMap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.map_outlined),
                label: const Text(
                  'Open Map',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          height: _mapVisible ? 330 : 0,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _mapVisible
                ? Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: hasRoute
                              ? widget.routePoints.last
                              : _defaultCenter,
                          zoom: hasRoute ? 15 : 12,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                        compassEnabled: true,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _mapInitialized = true;
                          _mapLoadTimer?.cancel();
                          _fitCameraToRoute();
                        },
                        onTap: _handleMapTap,
                      ),
                      if (_mapLoadTimedOut)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.55),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(16),
                            child: const Text(
                              'Map is taking too long to load.\nCheck your Google Maps API key and billing setup for web.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Row(
                          children: [
                            _MapActionButton(
                              icon: Icons.undo,
                              label: 'Undo',
                              onPressed: _undoLastPoint,
                            ),
                            const SizedBox(width: 8),
                            _MapActionButton(
                              icon: Icons.delete_outline,
                              label: 'Clear',
                              onPressed: _clearRoute,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            hasRoute
                                ? '${widget.routePoints.length} point(s) selected'
                                : 'Tap anywhere on the map to add route points',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              ElevatedButton(
                onPressed: hasRoute ? widget.onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.textDark,
                  disabledBackgroundColor: AppColors.neonGreen.withValues(
                    alpha: 0.45,
                  ),
                  disabledForegroundColor: AppColors.textDark.withValues(
                    alpha: 0.8,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              if (!hasRoute)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Please create a route on the map before continuing.',
                            ),
                            backgroundColor: Colors.orange[700],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.onBack,
          child: Text(
            'Back',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: widget.isDarkMode
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _MapActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
