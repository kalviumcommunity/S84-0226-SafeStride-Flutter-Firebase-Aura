import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/app_colors.dart';
import '../controllers/navigation_controller.dart';
import '../models/route_model.dart';
import '../services/routing_service.dart';

// ── NavigationScreen ──────────────────────────────────────────────────────────

/// Full-screen navigation view that shows a live route on Google Maps.
///
/// Opened when the user taps "Start Navigation" on [RouteDetailScreen].
/// Requires [route.latitude] and [route.longitude] to be set.
///
/// Features:
///   - Route polyline fetched from OSRM (free, no API key).
///   - User position marker updated in real time via Geolocator stream.
///   - Camera continuously follows the user while navigating.
///   - Auto-reroutes when user drifts > 50 m off the current polyline.
///   - Distance + ETA panel at the bottom.
///   - Re-centre FAB to snap the camera back to the user.
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({
    super.key,
    required this.route,
    this.profile = RoutingProfile.foot,
  });

  /// The destination trail / park. Must have non-null [RouteModel.latitude]
  /// and [RouteModel.longitude].
  final RouteModel route;

  /// OSRM transport profile. Defaults to walking ([RoutingProfile.foot]).
  final RoutingProfile profile;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late final NavigationController _controller;
  final Completer<GoogleMapController> _mapCompleter = Completer();

  @override
  void initState() {
    super.initState();

    _controller = NavigationController(
      destination: LatLng(widget.route.latitude!, widget.route.longitude!),
      destinationName: widget.route.name,
      profile: widget.profile,
    );

    // Rebuild the widget tree on every controller state change.
    _controller.addListener(_onUpdate);

    // Kick off GPS acquisition + initial OSRM request.
    _controller.start();
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  // ── Controller listener ────────────────────────────────────────────────────

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
    // Keep camera centred on the user as they move.
    _centerOnUser();
  }

  Future<void> _centerOnUser() async {
    final pos = _controller.userPosition;
    if (pos == null) return;
    final mapCtrl = await _mapCompleter.future;
    await mapCtrl.animateCamera(CameraUpdate.newLatLng(pos));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBar(),
          if (_controller.isLoading) _buildLoadingOverlay(),
          if (!_controller.isLoading && _controller.errorMessage != null)
            _buildBanner(
              message: _controller.errorMessage!,
              color: AppColors.safetyLow,
              icon: Icons.error_outline,
            ),
          if (_controller.isRerouting)
            _buildBanner(
              message: 'Recalculating route…',
              color: AppColors.safetyMedium,
              icon: Icons.refresh,
              showSpinner: true,
            ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  // ── Map layer ──────────────────────────────────────────────────────────────

  Widget _buildMap() {
    // Start the camera at the destination until GPS provides the user pos.
    final initial =
        _controller.userPosition ??
        LatLng(widget.route.latitude!, widget.route.longitude!);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initial, zoom: 16),
      onMapCreated: (ctrl) {
        if (!_mapCompleter.isCompleted) _mapCompleter.complete(ctrl);
      },
      // The blue dot from myLocationEnabled tracks the user so we don't need
      // a duplicate user marker; we keep one for the InfoWindow label only.
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: _buildMarkers(),
      polylines: _buildPolylines(),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Destination marker — green hue to match SafeStride branding.
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.route.latitude!, widget.route.longitude!),
        infoWindow: InfoWindow(
          title: widget.route.name,
          snippet: 'Destination',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    // User position marker — azure hue to contrast with the destination.
    if (_controller.userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _controller.userPosition!,
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (_controller.routePoints.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _controller.routePoints,
        color: AppColors.neonGreen,
        width: 5,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  // ── UI panels ──────────────────────────────────────────────────────────────

  /// Top bar with a close button and the destination name.
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Close / exit navigation.
              _CircleButton(
                icon: Icons.close,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              // Route name pill.
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_walk,
                        color: AppColors.neonGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.route.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Semi-transparent overlay with a spinner shown while fetching the route.
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.neonGreen),
            SizedBox(height: 16),
            Text(
              'Calculating route…',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// Floating banner for errors and rerouting notices.
  Widget _buildBanner({
    required String message,
    required Color color,
    required IconData icon,
    bool showSpinner = false,
  }) {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (showSpinner)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom panel showing distance, ETA, and the re-centre button.
  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withOpacity(0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Distance info pill.
            _InfoPill(
              icon: Icons.straighten,
              label: 'Distance',
              value: _controller.routeDistance.isEmpty
                  ? '—'
                  : _controller.routeDistance,
            ),
            const SizedBox(width: 24),
            // ETA info pill.
            _InfoPill(
              icon: Icons.access_time,
              label: 'ETA',
              value: _controller.routeEta.isEmpty ? '—' : _controller.routeEta,
            ),
            const Spacer(),
            // Re-centre camera on user position.
            _CircleButton(
              icon: Icons.my_location,
              color: AppColors.neonGreen,
              iconColor: AppColors.textDark,
              onTap: _centerOnUser,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable helper widgets ────────────────────────────────────────────────────

/// A small circular icon button used in the top bar and bottom panel.
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color ?? AppColors.darkBlue.withOpacity(0.88),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (color ?? Colors.black).withOpacity(0.35),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

/// A labelled value display used in the bottom panel.
class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.neonGreen, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: AppColors.textGray, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
