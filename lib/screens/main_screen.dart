import 'package:flutter/material.dart';

import '../screens/map_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/add_route_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/profile_screen.dart';
import '../models/route_model.dart';
import '../constants/app_colors.dart';
import '../config/routes.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeTab = 0;
  bool _isDarkMode = false;

  void _handleRouteSelect(RouteModel route) {
    Navigator.pushNamed(
      context,
      AppRoutes.routeDetail,
      arguments: RouteDetailArguments(
        route: route,
        isDarkMode: _isDarkMode,
      ),
    );
  }

  void _toggleDarkMode() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  Widget _renderScreen() {
    switch (_activeTab) {
      case 0:
        return MapScreen(
          onRouteSelect: _handleRouteSelect,
          isDarkMode: _isDarkMode,
        );
      case 1:
        return DiscoverScreen(
          onRouteSelect: _handleRouteSelect,
          isDarkMode: _isDarkMode,
        );
      case 2:
        return AddRouteScreen(isDarkMode: _isDarkMode);
      case 3:
        return AlertsScreen(isDarkMode: _isDarkMode);
      case 4:
        return ProfileScreen(
          isDarkMode: _isDarkMode,
          onToggleDarkMode: _toggleDarkMode,
        );
      default:
        return MapScreen(
          onRouteSelect: _handleRouteSelect,
          isDarkMode: _isDarkMode,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _isDarkMode
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
            _renderScreen(),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
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
              color: _isDarkMode ? AppColors.mediumBlue : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isDarkMode ? 0.3 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.map, 0),
                _buildNavItem(Icons.explore, 1),
                _buildNavItem(Icons.add_circle, 2),
                _buildNavItem(Icons.notifications, 3),
                _buildNavItem(Icons.person, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isActive = _activeTab == index;

    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Icon(
        icon,
        color: isActive
            ? AppColors.neonGreen
            : _isDarkMode
                ? Colors.grey[400]
                : Colors.grey[500],
      ),
    );
  }
}
