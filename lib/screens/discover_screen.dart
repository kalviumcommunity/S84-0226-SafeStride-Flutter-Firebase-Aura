import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../constants/app_colors.dart';
import '../constants/mock_data.dart';

class DiscoverScreen extends StatefulWidget {
  final Function(RouteModel) onRouteSelect;
  final bool isDarkMode;

  const DiscoverScreen({
    Key? key,
    required this.onRouteSelect,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String selectedCategory = 'trending';
  String searchQuery = '';

  final List<Map<String, dynamic>> categories = [
    {'id': 'trending', 'name': 'Trending', 'icon': Icons.trending_up},
    {'id': 'safe', 'name': 'Safest', 'icon': Icons.shield},
    {'id': 'top', 'name': 'Top Rated', 'icon': Icons.emoji_events},
    {'id': 'nearby', 'name': 'Nearby', 'icon': Icons.near_me},
  ];

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
            padding: const EdgeInsets.only(left: 24, right: 24, top: 64, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find your perfect route',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
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
                        color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[500],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => setState(() => searchQuery = value),
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search routes...',
                            hintStyle: TextStyle(
                              color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
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
                    onTap: () => setState(() => selectedCategory = category['id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          const SizedBox(height: 24),
          // Featured Routes
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                Text(
                  'Featured Routes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...MockData.featuredRoutes.map((route) => _buildRouteCard(route)).toList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(RouteModel route) {
    return GestureDetector(
      onTap: () => widget.onRouteSelect(route),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.skyBlue,
                      ],
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      color: AppColors.getSafetyColor(route.safety).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.getSafetyColor(route.safety).withOpacity(0.4),
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
                      color: widget.isDarkMode ? Colors.white : AppColors.textDark,
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
                              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${route.reviews})',
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
