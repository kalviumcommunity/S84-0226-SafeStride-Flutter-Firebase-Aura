import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/place.dart';
import '../models/route_model.dart';
import '../constants/app_colors.dart';
import '../constants/mock_data.dart';
import '../config/routes.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../services/discovery_engine.dart';

class DiscoverScreen extends StatefulWidget {
  final Function(RouteModel) onRouteSelect;
  final bool isDarkMode;

  const DiscoverScreen({
    super.key,
    required this.onRouteSelect,
    required this.isDarkMode,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String selectedCategory = 'trending';
  String searchQuery = '';
  int _minSafetyFilter = 0; // 0 means no filter
  bool isGridView = false; // Toggle between List and Grid view
  final TextEditingController _searchController = TextEditingController();

  // ── Nearby trails state ─────────────────────────────────────────────────────
  List<Place> _nearbyTrails = const [];
  bool _trailsLoading = false;
  String? _trailsError;

  // ── Search-location featured routes state ──────────────────────────────────
  List<RouteModel> _searchLocationRoutes = const [];
  bool _searchLocationLoading = false;

  // API key is read from lib/config/api_config.dart — update it there.

  @override
  void initState() {
    super.initState();
    _fetchNearbyTrails();
    _loadFeaturedRoutesFromCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Obtains the user's GPS position, then queries PlacesService for nearby
  /// parks and trails within 5 km. Updates [_nearbyTrails] via setState.
  Future<void> _fetchNearbyTrails() async {
    setState(() {
      _trailsLoading = true;
      _trailsError = null;
    });
    try {
      final position = await LocationService.getCurrentLocation();
      final places = await PlacesService().getNearbyTrails(
        position.latitude,
        position.longitude,
      );
      if (mounted) setState(() => _nearbyTrails = places);
    } on LocationServiceException catch (e) {
      if (mounted) setState(() => _trailsError = e.message);
    } on PlacesException catch (e) {
      if (mounted) {
        setState(() => _trailsError = _friendlyPlacesError(e.message));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _trailsError = 'Could not load nearby trails.');
      }
    } finally {
      if (mounted) setState(() => _trailsLoading = false);
    }
  }

  String _friendlyPlacesError(String message) {
    if (message.contains('HTTP 504') ||
        message.contains('HTTP 503') ||
        message.contains('HTTP 502') ||
        message.contains('HTTP 429')) {
      return 'Trail data server is busy. Please tap refresh in a few seconds.';
    }
    return message;
  }

  Future<void> _searchByLocation(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      if (mounted) {
        setState(() {
          _searchLocationRoutes = const [];
        });
      }
      return;
    }

    if (mounted) setState(() => _searchLocationLoading = true);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&limit=1&q=${Uri.encodeQueryComponent(trimmed)}',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'SafeStride/1.0 (Route Discovery)'},
      );

      if (response.statusCode != 200) {
        throw Exception('Location search failed');
      }

      final data = json.decode(response.body) as List<dynamic>;
      if (data.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No matching location found.')),
          );
        }
        return;
      }

      final first = data.first as Map<String, dynamic>;
      final lat = double.parse(first['lat'] as String);
      final lng = double.parse(first['lon'] as String);

      final places = await PlacesService().getNearbyTrails(lat, lng);
      final localizedRoutes = places
          .asMap()
          .entries
          .map((entry) => _placeToRoute(entry.key + 1, entry.value, lat, lng))
          .toList();

      if (mounted) {
        setState(() {
          _searchLocationRoutes = localizedRoutes;
          selectedCategory = 'nearby';
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not search this location.')),
        );
      }
    } finally {
      if (mounted) setState(() => _searchLocationLoading = false);
    }
  }

  Future<void> _loadFeaturedRoutesFromCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      final places = await PlacesService().getNearbyTrails(
        position.latitude,
        position.longitude,
      );

      if (!mounted || places.isEmpty) return;

      final localizedRoutes = places
          .asMap()
          .entries
          .map(
            (entry) => _placeToRoute(
              entry.key + 1,
              entry.value,
              position.latitude,
              position.longitude,
            ),
          )
          .toList();

      setState(() {
        _searchLocationRoutes = localizedRoutes;
      });
    } catch (_) {
      // Keep mock fallback when location/overpass fails.
    }
  }

  RouteModel _placeToRoute(
    int id,
    Place place,
    double centerLat,
    double centerLng,
  ) {
    final distM = Geolocator.distanceBetween(
      centerLat,
      centerLng,
      place.latitude,
      place.longitude,
    );

    final distanceText = distM >= 1000
        ? '${(distM / 1000).toStringAsFixed(1)} km'
        : '${distM.round()} m';

    final rating = place.rating ?? 4.2;
    final safety = ((rating / 5.0) * 100).clamp(60, 98).round();

    String? tag;
    if (id % 3 == 1) {
      tag = 'Trending';
    } else if (id % 3 == 2) {
      tag = 'Popular';
    } else {
      tag = 'Safe';
    }

    return RouteModel(
      id: id,
      name: place.name,
      category: 'Walk',
      distance: distanceText,
      safety: safety,
      lighting: safety >= 85
          ? 'Excellent'
          : safety >= 70
          ? 'Good'
          : 'Moderate',
      traffic: 'Low',
      crowd: 'Moderate',
      reviews: (rating * 28).round(),
      rating: rating,
      image: 'local trail',
      emoji: '🌿',
      tag: tag,
      latitude: place.latitude,
      longitude: place.longitude,
    );
  }

  final List<Map<String, dynamic>> categories = [
    {'id': 'trending', 'name': 'Trending', 'icon': Icons.trending_up},
    {'id': 'safe', 'name': 'Safest', 'icon': Icons.shield},
    {'id': 'top', 'name': 'Top Rated', 'icon': Icons.emoji_events},
    {'id': 'nearby', 'name': 'Nearby', 'icon': Icons.near_me},
  ];

  List<RouteModel> get filteredRoutes {
    final source = _searchLocationRoutes.isNotEmpty
        ? _searchLocationRoutes
        : MockData.featuredRoutes;

    final filtered = DiscoveryEngine.filterRoutes(
      source: source,
      searchQuery: searchQuery,
      minSafetyFilter: _minSafetyFilter,
    );

    return DiscoveryEngine.sortRoutes(
      routes: filtered,
      selectedCategory: selectedCategory,
    );
  }

  Widget _buildSafetyFilterRow() {
    final filters = [
      {'label': 'All', 'minScore': 0},
      {'label': 'Safe (80%+)', 'minScore': 80},
      {'label': 'Very Safe (90%+)', 'minScore': 90},
      {'label': 'Safest (95%+)', 'minScore': 95},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = _minSafetyFilter == filter['minScore'];
          final minScore = filter['minScore'] as int;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? Colors.white
                      : (widget.isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _minSafetyFilter = minScore);
                }
              },
              selectedColor: AppColors.skyBlue,
              backgroundColor: widget.isDarkMode
                  ? AppColors.mediumBlue
                  : Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isActive
                      ? AppColors.skyBlue
                      : (widget.isDarkMode ? Colors.transparent : Colors.grey[300]!),
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? AppColors.darkBlue
          : AppColors.lightBackground,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDarkMode
                    ? [AppColors.lightBlue, Colors.transparent]
                    : [AppColors.lightBackground, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 64,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discover',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode
                            ? Colors.white
                            : AppColors.textDark,
                      ),
                    ),
                    // View Toggle Button
                    GestureDetector(
                      onTap: () => setState(() => isGridView = !isGridView),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? AppColors.mediumBlue
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          isGridView ? Icons.list : Icons.grid_view,
                          color: widget.isDarkMode
                              ? AppColors.neonGreen
                              : AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Find your perfect route',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? AppColors.mediumBlue
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: widget.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[500],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => searchQuery = value),
                          onSubmitted: _searchByLocation,
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search routes...',
                            hintStyle: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchLocationLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        GestureDetector(
                          onTap: () =>
                              _searchByLocation(_searchController.text),
                          child: Icon(
                            Icons.near_me,
                            color: widget.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[500],
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Categories
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isActive = selectedCategory == category['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => selectedCategory = category['id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.neonGradient : null,
                        color: isActive
                            ? null
                            : widget.isDarkMode
                            ? AppColors.mediumBlue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.neonGreen.withOpacity(0.3),
                                  blurRadius: 16,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                ),
                              ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            category['icon'],
                            size: 16,
                            color: isActive
                                ? AppColors.textDark
                                : widget.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppColors.textDark
                                  : widget.isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Safety Filters
          _buildSafetyFilterRow(),
          const SizedBox(height: 24),
          // Featured Routes
          Expanded(child: isGridView ? _buildGridView() : _buildListView()),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? AppColors.mediumBlue.withOpacity(0.5)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: widget.isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No routes found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your search or safety filters to find more results.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  searchQuery = '';
                  _minSafetyFilter = 0;
                  _searchController.clear();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Clear all filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.skyBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ListView.builder implementation
  Widget _buildListView() {
    final routes = filteredRoutes;

    if (routes.isEmpty) {
      return _buildEmptyState();
    }
    // Slot layout:
    //  0                  → "Featured Routes" header
    //  1 … routes.length  → route cards
    //  routes.length + 1  → nearby trails section
    //  routes.length + 2  → community routes section
    //  routes.length + 3  → bottom spacing
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: routes.length + 4,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Featured Routes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
          );
        }

        if (index == routes.length + 1) {
          return _buildNearbyTrailsSection();
        }

        if (index == routes.length + 2) {
          return _buildCommunityRoutesSection();
        }

        if (index == routes.length + 3) {
          return const SizedBox(height: 100);
        }

        final route = routes[index - 1];
        return _buildRouteCard(route);
      },
    );
  }

  // ── Nearby Trails section ──────────────────────────────────────────────────

  /// Builds the full "Nearby Parks & Trails" section with header, loading,
  /// error, empty, and populated states.
  Widget _buildNearbyTrailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        // Section header with refresh button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nearby Parks & Trails',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: _trailsLoading ? null : _fetchNearbyTrails,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? AppColors.mediumBlue
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: _trailsLoading
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.isDarkMode
                              ? AppColors.neonGreen
                              : AppColors.primaryBlue,
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: widget.isDarkMode
                            ? AppColors.neonGreen
                            : AppColors.primaryBlue,
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Parks and trails within 10 km of you',
          style: TextStyle(
            fontSize: 13,
            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        // ── Loading state ───────────────────────────────────────────────────
        if (_trailsLoading && _nearbyTrails.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(
                color: widget.isDarkMode
                    ? AppColors.neonGreen
                    : AppColors.primaryBlue,
              ),
            ),
          )
        // ── Error state ─────────────────────────────────────────────────────
        else if (_trailsError != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_off_outlined,
                  color: widget.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[500],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _trailsError!,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isDarkMode
                          ? Colors.grey[300]
                          : AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          )
        // ── Empty state ─────────────────────────────────────────────────────
        else if (_nearbyTrails.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.forest_outlined,
                  color: widget.isDarkMode
                      ? AppColors.neonGreen
                      : AppColors.primaryBlue,
                ),
                const SizedBox(width: 12),
                Text(
                  'No nearby trails found.',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.grey[300]
                        : AppColors.textDark,
                  ),
                ),
              ],
            ),
          )
        // ── Populated state ─────────────────────────────────────────────────
        else
          Column(
            children: _nearbyTrails
                .map((place) => _buildPlaceCard(place))
                .toList(),
          ),
      ],
    );
  }

  /// Renders a single nearby-trail card for the given [place].
  Widget _buildPlaceCard(Place place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDarkMode ? 0.25 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Left icon panel ───────────────────────────────────────────────
          Container(
            width: 80,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: widget.isDarkMode
                    ? [AppColors.lightBlue, AppColors.mediumBlue]
                    : [AppColors.lightBackground, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.park_outlined,
                size: 36,
                color: widget.isDarkMode
                    ? AppColors.neonGreen
                    : AppColors.primaryBlue,
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: widget.isDarkMode
                          ? Colors.white
                          : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Address
                  if (place.address != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: widget.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[500],
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            place.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  // Coordinates row
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 12,
                        color: widget.isDarkMode
                            ? Colors.grey[500]
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${place.latitude.toStringAsFixed(4)}, '
                        '${place.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Rating badge ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: place.rating != null
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? AppColors.neonGreen.withOpacity(0.15)
                          : AppColors.neonGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.neonGreen,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          place.rating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: widget.isDarkMode
                                ? AppColors.neonGreen
                                : AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  )
                : Icon(
                    Icons.chevron_right_rounded,
                    color: widget.isDarkMode
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityRoutesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Text(
          'Community Routes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.isDarkMode ? Colors.white : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Routes submitted by the SafeStride community',
          style: TextStyle(
            fontSize: 13,
            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirestoreService().getRoutesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Could not load community routes.',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              );
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? AppColors.mediumBlue
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_road,
                        color: widget.isDarkMode
                            ? AppColors.neonGreen
                            : AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No community routes yet. Be the first to add one!',
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.grey[300]
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildCommunityRouteCard(data);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommunityRouteCard(Map<String, dynamic> data) {
    final name = data['name'] as String? ?? 'Unnamed Route';
    final category = data['category'] as String? ?? '—';
    final distance = data['distance'] as String? ?? '—';
    final description = data['description'] as String? ?? '';
    final isRunner = category.toLowerCase().contains('runner');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDarkMode ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  (widget.isDarkMode
                          ? AppColors.neonGreen
                          : AppColors.primaryBlue)
                      .withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                isRunner ? '🏃' : '🚴',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: widget.isDarkMode
                        ? Colors.white
                        : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 13,
                      color: widget.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.directions,
                      size: 13,
                      color: widget.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDarkMode
                          ? Colors.grey[500]
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Community',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode
                    ? AppColors.neonGreen
                    : AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // GridView.builder implementation
  Widget _buildGridView() {
    final routes = filteredRoutes;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Featured Routes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final route = routes[index];
              return _buildGridCard(route);
            }, childCount: routes.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // Compact card for grid view
  Widget _buildGridCard(RouteModel route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.routeDetail,
          arguments: RouteDetailArguments(
            route: route,
            isDarkMode: widget.isDarkMode,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.isDarkMode ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.skyBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        route.emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  // Safety Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getSafetyColor(
                          route.safety,
                        ).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${route.safety}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      route.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode
                            ? Colors.white
                            : AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.distance,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.neonGreen,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              route.rating.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(RouteModel route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.routeDetail,
          arguments: RouteDetailArguments(
            route: route,
            isDarkMode: widget.isDarkMode,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.isDarkMode ? 0.3 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Container(
                  height: 192,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.skyBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      route.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),
                Container(
                  height: 192,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Tag Badge
                if (route.tag != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        route.tag!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                // Safety Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.getSafetyColor(
                        route.safety,
                      ).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.getSafetyColor(
                            route.safety,
                          ).withOpacity(0.4),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield,
                          color: AppColors.getSafetyColor(route.safety),
                          size: 20,
                        ),
                        Text(
                          '${route.safety}%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode
                          ? Colors.white
                          : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            route.distance,
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isDarkMode
                                  ? AppColors.lightBlue
                                  : const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              route.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.isDarkMode
                                    ? Colors.grey[300]
                                    : AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.neonGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            route.rating.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${route.reviews})',
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
