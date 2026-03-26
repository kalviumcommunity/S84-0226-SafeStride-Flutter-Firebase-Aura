import 'package:flutter/material.dart';

import '../screens/map_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/add_route_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/profile_screen.dart';
import '../models/route_model.dart';
import '../constants/app_colors.dart';
import '../config/routes.dart';
import '../screens/responsive_layout.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeTab = 0;

  void _handleRouteSelect(RouteModel route) {
    Navigator.pushNamed(
      context,
      AppRoutes.routeDetail,
      arguments: RouteDetailArguments(route: route),
    );
  }

  Widget _renderScreen() {
    switch (_activeTab) {
      case 0:
        return MapScreen(onRouteSelect: _handleRouteSelect);
      case 1:
        return DiscoverScreen(onRouteSelect: _handleRouteSelect);
      case 2:
        return const AddRouteScreen();
      case 3:
        return const AlertsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return MapScreen(onRouteSelect: _handleRouteSelect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  colors: [AppColors.darkBlue, AppColors.darkBlue],
                )
              : const LinearGradient(
                  colors: [
                    AppColors.lightBackground,
                    AppColors.lightGray,
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: _renderScreen()),
            _buildBottomNav(isDarkMode),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ResponsiveLayout()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.dashboard_customize, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNav(bool isDarkMode) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 448),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.mediumBlue : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color : Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.map, 0, isDarkMode),
                _buildNavItem(Icons.explore, 1, isDarkMode),
                _buildNavItem(Icons.add_circle, 2, isDarkMode),
                _buildNavItem(Icons.notifications, 3, isDarkMode),
                _buildNavItem(Icons.person, 4, isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, bool isDarkMode) {
    final isActive = _activeTab == index;

    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Icon(
        icon,
        color: isActive
            ? AppColors.neonGreen
            : isDarkMode
            ? Colors.grey[400]
            : Colors.grey[500],
      ),
    );
  }
}
