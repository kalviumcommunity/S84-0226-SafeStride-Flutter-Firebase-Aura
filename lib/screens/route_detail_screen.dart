import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../constants/app_colors.dart';
import '../constants/mock_data.dart';
import '../config/routes.dart';
import '../screens/navigation_screen.dart';
import '../services/routing_service.dart';
import 'route_safety_screen.dart';

class RouteDetailScreen extends StatelessWidget {
  final RouteModel? route;
  final VoidCallback? onBack;

  const RouteDetailScreen({
    super.key,
    this.route,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments from route if not passed directly
    final args = route == null
        ? ModalRoute.of(context)!.settings.arguments as RouteDetailArguments?
        : null;

    final routeData = route ?? args!.route;
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: darkMode ? AppColors.darkBlue : AppColors.lightGray,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Section
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Hero Image
                    Container(
                      height: 320,
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                      ),
                      child: Center(
                        child: Text(
                          routeData.emoji,
                          style: const TextStyle(fontSize: 120),
                        ),
                      ),
                    ),
                    // Gradient Overlay
                    Container(
                      height: 320,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Header Actions
                    Positioned(
                      top: 48,
                      left: 24,
                      right: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (onBack != null) {
                                onBack!();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.share,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bookmark_border,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Safety Badge
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.getSafetyColor(
                            routeData.safety,
                          ).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getSafetyColor(
                                routeData.safety,
                              ).withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield,
                              color: AppColors.getSafetyColor(routeData.safety),
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${routeData.safety}%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Safe',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Route Info
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 128,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routeData.name,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  routeData.category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  routeData.distance,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.neonGreen,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    routeData.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${routeData.reviews})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
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
              // Content Section
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats Grid
                    Transform.translate(
                      offset: const Offset(0, -32),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              Icons.map,
                              routeData.distance,
                              'Distance',
                              darkMode,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              Icons.light_mode,
                              routeData.lighting,
                              'Lighting',
                              darkMode,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.trending_up,
                            routeData.traffic,
                            'Traffic',
                            darkMode,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            Icons.people,
                            routeData.crowd,
                            'Crowd Level',
                            darkMode,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Rate Route Button (Navigates to Safety Rating Screen)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RouteSafetyRatingScreen(
                              route: routeData,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.rate_review),
                      label: const Text(
                        'Rate This Route',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Reviews Section
                    Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkMode ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...MockData.reviews
                        .map((review) => _buildReviewCard(review, darkMode))
                        ,
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
          // CTA Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: darkMode
                      ? [AppColors.darkBlue.withOpacity(0), AppColors.darkBlue]
                      : [Colors.white.withOpacity(0), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ElevatedButton(
                onPressed: () => _startNavigation(context, routeData),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.neonGreen.withOpacity(0.3),
                ),
                child: const Text(
                  'Start Navigation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    bool darkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode ? AppColors.mediumBlue : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(darkMode ? 0.3 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: darkMode ? AppColors.neonGreen : AppColors.primaryBlue,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkMode ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: darkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review, bool darkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode ? AppColors.mediumBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(darkMode ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.blueGradient,
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.author,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkMode ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        Text(
                          review.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: darkMode
                                ? Colors.grey[400]
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 16,
                          color: index < review.rating
                              ? AppColors.neonGreen
                              : darkMode
                              ? Colors.grey[600]
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.text,
            style: TextStyle(
              fontSize: 14,
              color: darkMode ? Colors.grey[300] : Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 16,
                color: darkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Helpful (${review.helpful})',
                style: TextStyle(
                  fontSize: 14,
                  color: darkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Opens [NavigationScreen] if the route has coordinates, otherwise shows
  /// a snackbar explaining that navigation is unavailable for this route.
  void _startNavigation(BuildContext context, RouteModel routeData) {
    if (routeData.latitude == null || routeData.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Navigation is not available for this route — no coordinates found.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            NavigationScreen(route: routeData, profile: RoutingProfile.foot),
      ),
    );
  }
}
