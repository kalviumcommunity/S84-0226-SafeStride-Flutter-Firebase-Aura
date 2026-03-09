import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_colors.dart';
import '../models/route_model.dart';
import '../config/routes.dart';
import '../services/location_service.dart';
import '../widgets/trail_card.dart';

// ── Dark-mode map style JSON ──────────────────────────────────────────────────

const String _kDarkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#0a1628"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8494a9"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0a1628"}]},
  {"featureType":"administrative","elementType":"geometry.fill","stylers":[{"color":"#1a2a42"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1a2a42"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#0d1f35"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#1e3050"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#1a2a42"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0d2137"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#0f1f3a"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#0a1f30"}]}
]
''';

// ── Trail data ────────────────────────────────────────────────────────────────

const List<TrailSpot> _kTrails = [
  TrailSpot(id: 1, name: 'Riverside Trail', lat: 37.7851, lng: -122.4423,
      distance: '5.2 km', lighting: 'Excellent', crowd: 'Moderate',
      safety: 95, emoji: '🏃‍♂️', category: 'Runner'),
  TrailSpot(id: 2, name: 'Park Loop', lat: 37.7681, lng: -122.4326,
      distance: '3.8 km', lighting: 'Good', crowd: 'Low',
      safety: 88, emoji: '🏃‍♀️', category: 'Runner'),
  TrailSpot(id: 3, name: 'Forest Run', lat: 37.7714, lng: -122.4467,
      distance: '9.4 km', lighting: 'Good', crowd: 'Low',
      safety: 91, emoji: '🏃', category: 'Runner'),
  TrailSpot(id: 4, name: 'Lake Path', lat: 37.7794, lng: -122.4102,
      distance: '7.1 km', lighting: 'Moderate', crowd: 'High',
      safety: 79, emoji: '🚴‍♀️', category: 'Cyclist'),
  TrailSpot(id: 5, name: 'Harbor Circuit', lat: 37.7969, lng: -122.4089,
      distance: '12.6 km', lighting: 'Excellent', crowd: 'Moderate',
      safety: 86, emoji: '🚴‍♂️', category: 'Cyclist'),
];

// ── Map Screen ────────────────────────────────────────────────────────────────

class MapScreen extends StatefulWidget {
  final Function(RouteModel) onRouteSelect;
  final bool isDarkMode;

  const MapScreen({
    Key? key,
    required this.onRouteSelect,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapCompleter = Completer();
  final ScrollController _cardScroll = ScrollController();

  String _mode = 'runner';
  int _selectedId = 1;
  bool _locationLoading = true;
  LatLng _center = const LatLng(37.7749, -122.4194);
  Set<Marker> _markers = {};

  // card width (252) + right margin (14) = 266
  static const double _cardStride = 266.0;

  @override
  void initState() {
    super.initState();
    _buildMarkers();
    _fetchLocation();
  }

  @override
  void dispose() {
    _cardScroll.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _locationLoading = true);
    final pos = await LocationService.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _center = LatLng(pos.latitude, pos.longitude);
      _locationLoading = false;
    });
    if (_mapCompleter.isCompleted) {
      final ctrl = await _mapCompleter.future;
      ctrl.animateCamera(CameraUpdate.newLatLngZoom(_center, 13.5));
    }
  }

  void _buildMarkers() {
    _markers = _filteredTrails.map((t) {
      final hue = t.safety >= 85
          ? BitmapDescriptor.hueGreen
          : t.safety >= 70
              ? BitmapDescriptor.hueYellow
              : BitmapDescriptor.hueRed;
      return Marker(
        markerId: MarkerId('${t.id}'),
        position: LatLng(t.lat, t.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(
          title: t.name,
          snippet: '${t.distance} · Safety ${t.safety}%',
        ),
        onTap: () => _onMarkerTapped(t.id),
      );
    }).toSet();
  }

  void _onMarkerTapped(int id) {
    setState(() => _selectedId = id);
    final idx = _filteredTrails.indexWhere((t) => t.id == id);
    if (idx >= 0 && _cardScroll.hasClients) {
      _cardScroll.animateTo(
        idx * _cardStride,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _onCardTapped(TrailSpot trail) async {
    setState(() => _selectedId = trail.id);
    if (_mapCompleter.isCompleted) {
      final ctrl = await _mapCompleter.future;
      await ctrl.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(trail.lat, trail.lng), 15.0),
      );
      ctrl.showMarkerInfoWindow(MarkerId('${trail.id}'));
    }
  }

  void _onModeChanged(String newMode) {
    if (_mode == newMode) return;
    setState(() {
      _mode = newMode;
      _buildMarkers();
      final trails = _filteredTrails;
      _selectedId = trails.isNotEmpty ? trails.first.id : -1;
    });
    if (_cardScroll.hasClients) _cardScroll.jumpTo(0);
  }

  List<TrailSpot> get _filteredTrails => _kTrails
      .where((t) => _mode == 'runner'
          ? t.category == 'Runner'
          : t.category == 'Cyclist')
      .toList();

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Trails',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode
                        ? Colors.white
                        : AppColors.textDark)),
            const SizedBox(height: 8),
            Text('Advanced filters coming soon.',
                style: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600])),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 28),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trails = _filteredTrails;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _center, zoom: 13.5),
            onMapCreated: (ctrl) {
              if (!_mapCompleter.isCompleted) _mapCompleter.complete(ctrl);
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            style: widget.isDarkMode ? _kDarkMapStyle : null,
            padding: const EdgeInsets.only(top: 130, bottom: 260),
          ),

          if (_locationLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.18),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              isDarkMode: widget.isDarkMode,
              mode: _mode,
              onModeChanged: _onModeChanged,
            ),
          ),

          Positioned(
            bottom: 298,
            right: 16,
            child: _MapFab(
              icon: Icons.my_location,
              isDarkMode: widget.isDarkMode,
              onTap: _fetchLocation,
            ),
          ),

          Positioned(
            bottom: 246,
            right: 16,
            child: _MapFab(
              icon: Icons.tune,
              isDarkMode: widget.isDarkMode,
              onTap: _showFilterSheet,
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomPanel(
              trails: trails,
              selectedId: _selectedId,
              isDarkMode: widget.isDarkMode,
              cardScroll: _cardScroll,
              onCardTap: _onCardTapped,
              onViewDetails: (trail) {
                final model = trail.toRouteModel();
                widget.onRouteSelect(model);
                Navigator.pushNamed(
                  context,
                  AppRoutes.routeDetail,
                  arguments: RouteDetailArguments(
                    route: model,
                    isDarkMode: widget.isDarkMode,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── _TopBar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool isDarkMode;
  final String mode;
  final ValueChanged<String> onModeChanged;

  const _TopBar({
    required this.isDarkMode,
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isDarkMode ? AppColors.darkBlue : Colors.white)
                .withOpacity(isDarkMode ? 0.97 : 0.95),
            (isDarkMode ? AppColors.darkBlue : Colors.white).withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.60, 1.0],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TrailSync',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        color: isDarkMode ? Colors.white : AppColors.textDark)),
                Text('Explore nearby trails',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600])),
              ],
            ),
          ),
          _ModeToggle(
              isDarkMode: isDarkMode,
              mode: mode,
              onModeChanged: onModeChanged),
        ],
      ),
    );
  }
}

// ── _ModeToggle ───────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final bool isDarkMode;
  final String mode;
  final ValueChanged<String> onModeChanged;

  const _ModeToggle({
    required this.isDarkMode,
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.mediumBlue
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _pill('runner', '🏃', 'Runner'),
        _pill('cyclist', '🚴', 'Cyclist'),
      ]),
    );
  }

  Widget _pill(String value, String emoji, String label) {
    final active = mode == value;
    return GestureDetector(
      onTap: () => onModeChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: active ? AppColors.neonGradient : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: AppColors.neonGreen.withOpacity(0.38),
                      blurRadius: 10)
                ]
              : null,
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? AppColors.textDark
                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]))),
        ]),
      ),
    );
  }
}

// ── _MapFab ───────────────────────────────────────────────────────────────────

class _MapFab extends StatelessWidget {
  final IconData icon;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _MapFab(
      {required this.icon, required this.isDarkMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.mediumBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Icon(icon,
            color: isDarkMode ? AppColors.neonGreen : AppColors.primaryBlue,
            size: 20),
      ),
    );
  }
}

// ── _BottomPanel ──────────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  final List<TrailSpot> trails;
  final int selectedId;
  final bool isDarkMode;
  final ScrollController cardScroll;
  final ValueChanged<TrailSpot> onCardTap;
  final ValueChanged<TrailSpot> onViewDetails;

  const _BottomPanel({
    required this.trails,
    required this.selectedId,
    required this.isDarkMode,
    required this.cardScroll,
    required this.onCardTap,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkBlue.withOpacity(0.97)
            : Colors.white.withOpacity(0.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nearby Trails',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppColors.textDark)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.neonGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('${trails.length} found',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppColors.neonGreen
                              : AppColors.primaryBlue)),
                ),
              ],
            ),
          ),

          // Horizontal card list
          SizedBox(
            height: 176,
            child: trails.isEmpty
                ? Center(
                    child: Text('No trails for this mode.',
                        style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600])))
                : ListView.builder(
                    controller: cardScroll,
                    scrollDirection: Axis.horizontal,
                    itemCount: trails.length,
                    padding: const EdgeInsets.fromLTRB(20, 2, 6, 2),
                    itemBuilder: (_, i) {
                      final trail = trails[i];
                      return TrailCard(
                        trail: trail,
                        isSelected: trail.id == selectedId,
                        isDarkMode: isDarkMode,
                        onTap: () => onCardTap(trail),
                        onViewDetails: () => onViewDetails(trail),
                      );
                    },
                  ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }
}
