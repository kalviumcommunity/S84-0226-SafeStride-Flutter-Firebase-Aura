import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

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
  final TextEditingController _searchController = TextEditingController();
  bool _mapVisible = false;
  bool _mapInitialized = false;
  bool _mapLoadTimedOut = false;
  bool _isSearching = false;
  bool _isLocating = false;
  List<_PlaceSuggestion> _searchResults = <_PlaceSuggestion>[];
  LatLng? _currentLocation;
  DateTime? _suppressMapTapUntil;
  Timer? _mapLoadTimer;

  Set<Marker> get _markers {
    return widget.routePoints.asMap().entries.map((entry) {
      final int index = entry.key;
      final LatLng point = entry.value;
      final bool isStart = index == 0;

      return Marker(
        markerId: MarkerId('route_point_$index'),
        position: point,
        draggable: true,
        onDragEnd: (LatLng updatedPosition) {
          _updateRoutePoint(index, updatedPosition);
        },
        infoWindow: InfoWindow(
          title: isStart ? '📍 Start Point' : '📍 Route Point ${index + 1}',
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
    final DateTime now = DateTime.now();
    if (_suppressMapTapUntil != null && now.isBefore(_suppressMapTapUntil!)) {
      return;
    }

    debugPrint(
      '[LocationStep] Map tap captured at (${point.latitude}, ${point.longitude})',
    );
    // Append new tap point and bubble updated route back to the parent page.
    final List<LatLng> updated = List<LatLng>.from(widget.routePoints)
      ..add(point);
    widget.onRoutePointsChanged(updated);
  }

  Future<void> _openMap() async {
    setState(() {
      _mapVisible = true;
      _mapLoadTimedOut = false;
      _mapInitialized = false;
    });

    await _resolveCurrentLocation(moveCamera: true);

    _mapLoadTimer?.cancel();
    _mapLoadTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || _mapInitialized) return;
      setState(() {
        _mapLoadTimedOut = true;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _fitCameraToRoute());
  }

  Future<void> _resolveCurrentLocation({bool moveCamera = false}) async {
    if (_isLocating) {
      return;
    }

    setState(() {
      _isLocating = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) {
        return;
      }

      final LatLng liveLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = liveLocation;
      });

      if (moveCamera && _mapController != null && widget.routePoints.isEmpty) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(liveLocation, 15),
        );
      }
    } catch (_) {
      // Graceful fallback to default center.
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _searchPlaces() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = <_PlaceSuggestion>[];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final Uri uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        <String, String>{'q': query, 'format': 'jsonv2', 'limit': '5'},
      );

      final http.Response response = await http.get(
        uri,
        headers: const <String, String>{
          'Accept': 'application/json',
          'User-Agent': 'SafeStride Flutter App',
        },
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Search failed. Please try again.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! List<dynamic>) {
        setState(() {
          _searchResults = <_PlaceSuggestion>[];
        });
        return;
      }

      final List<_PlaceSuggestion> results = decoded
          .map((dynamic item) => _PlaceSuggestion.fromJson(item))
          .whereType<_PlaceSuggestion>()
          .toList();

      setState(() {
        _searchResults = results;
      });

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No locations found for that search.'),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not search right now. Check your network.',
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _selectSearchResult(_PlaceSuggestion place) async {
    await _openMap();

    final LatLng selectedPoint = LatLng(place.latitude, place.longitude);
    final List<LatLng> updatedRoute = List<LatLng>.from(widget.routePoints)
      ..add(selectedPoint);

    widget.onRoutePointsChanged(updatedRoute);

    setState(() {
      _searchController.text = place.title;
      _searchResults = <_PlaceSuggestion>[];
    });

    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(selectedPoint, 16),
      );
    }
  }

  void _updateRoutePoint(int index, LatLng newPosition) {
    if (index < 0 || index >= widget.routePoints.length) {
      return;
    }

    final List<LatLng> updated = List<LatLng>.from(widget.routePoints);
    updated[index] = newPosition;
    widget.onRoutePointsChanged(updated);
  }

  void _undoLastPoint() {
    _suppressMapTapUntil = DateTime.now().add(
      const Duration(milliseconds: 450),
    );

    if (widget.routePoints.isEmpty) {
      return;
    }

    final List<LatLng> updated = List<LatLng>.from(widget.routePoints)
      ..removeLast();
    widget.onRoutePointsChanged(updated);
  }

  void _clearRoute() {
    _suppressMapTapUntil = DateTime.now().add(
      const Duration(milliseconds: 450),
    );

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
  void initState() {
    super.initState();
    _resolveCurrentLocation();
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
    _searchController.dispose();
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
            color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.mediumBlue : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: (Theme.of(context).brightness == Brightness.dark) ? 0.18 : 0.08,
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
                  color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap on the map to mark the starting point and route path',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: (Theme.of(context).brightness == Brightness.dark)
                      ? Colors.grey.shade300
                      : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Search a place, tap result to mark it, then drag 📍 markers to adjust',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchPlaces(),
                      style: TextStyle(
                        color: widget.isDarkMode
                            ? Colors.white
                            : AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search location',
                        hintStyle: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: widget.isDarkMode
                            ? AppColors.darkBlue
                            : AppColors.lightBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _isSearching ? null : _searchPlaces,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isSearching
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search, size: 18),
                      label: Text(_isSearching ? '...' : 'Mark'),
                    ),
                  ),
                ],
              ),
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 160),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? AppColors.darkBlue
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isDarkMode
                          ? AppColors.mediumBlue
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: widget.isDarkMode
                          ? AppColors.mediumBlue
                          : Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final _PlaceSuggestion result = _searchResults[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.place_outlined),
                        title: Text(
                          result.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: widget.isDarkMode
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                        ),
                        subtitle: Text(
                          result.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                        ),
                        onTap: () => _selectSearchResult(result),
                      );
                    },
                  ),
                ),
              ],
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
                label: Text(
                  _isLocating ? 'Locating...' : 'Open Map',
                  style: const TextStyle(fontWeight: FontWeight.w700),
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
                              : (_currentLocation ?? _defaultCenter),
                          zoom: hasRoute ? 15 : 12,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        myLocationEnabled: true,
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
                              onPressed: () {
                                _suppressMapTapUntil = DateTime.now().add(
                                  const Duration(milliseconds: 450),
                                );
                                _undoLastPoint();
                              },
                            ),
                            const SizedBox(width: 8),
                            _MapActionButton(
                              icon: Icons.delete_outline,
                              label: 'Clear',
                              onPressed: () {
                                _suppressMapTapUntil = DateTime.now().add(
                                  const Duration(milliseconds: 450),
                                );
                                _clearRoute();
                              },
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
        LayoutBuilder(
          builder: (context, constraints) {
            final double targetWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;

            return SizedBox(
              width: targetWidth,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 62),
                child: ElevatedButton(
                  onPressed: () {
                    if (!hasRoute) {
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
                      return;
                    }

                    widget.onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasRoute
                        ? AppColors.neonGreen
                        : AppColors.neonGreen.withValues(alpha: 0.45),
                    foregroundColor: AppColors.textDark,
                    minimumSize: const Size(double.infinity, 62),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.onBack,
          child: Text(
            'Back',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: (Theme.of(context).brightness == Brightness.dark)
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

class _PlaceSuggestion {
  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;

  const _PlaceSuggestion({
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });

  static _PlaceSuggestion? fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final String? latRaw = json['lat'] as String?;
    final String? lonRaw = json['lon'] as String?;
    final String? displayName = json['display_name'] as String?;

    if (latRaw == null || lonRaw == null || displayName == null) {
      return null;
    }

    final double? lat = double.tryParse(latRaw);
    final double? lon = double.tryParse(lonRaw);
    if (lat == null || lon == null) {
      return null;
    }

    final List<String> parts = displayName
        .split(',')
        .map((String part) => part.trim())
        .where((String part) => part.isNotEmpty)
        .toList();

    final String title = parts.isNotEmpty ? parts.first : displayName;
    final String subtitle = parts.length > 1
        ? parts.sublist(1).take(3).join(', ')
        : 'Location result';

    return _PlaceSuggestion(
      title: title,
      subtitle: subtitle,
      latitude: lat,
      longitude: lon,
    );
  }
}
