import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/map_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/add_route_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/route_detail_screen.dart';
import 'models/route_model.dart';
import 'constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrailSync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.neonGreen),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeTab = 0;
  bool _isDarkMode = false;
  RouteModel? _selectedRoute;

  void _handleRouteSelect(RouteModel route) {
    setState(() => _selectedRoute = route);
  }

  void _handleBackToMap() {
    setState(() => _selectedRoute = null);
  }

  void _toggleDarkMode() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  Widget _renderScreen() {
    if (_selectedRoute != null) {
      return RouteDetailScreen(
        route: _selectedRoute!,
        onBack: _handleBackToMap,
        isDarkMode: _isDarkMode,
      );
    }

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
            if (_selectedRoute == null) _buildBottomNav(),
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
              color: _isDarkMode
                  ? AppColors.mediumBlue
                  : Colors.white,
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
                _buildNavItem(Icons.map, 'Map', 0),
                _buildNavItem(Icons.explore, 'Discover', 1),
                _buildFAB(),
                _buildNavItem(Icons.notifications, 'Alerts', 3),
                _buildNavItem(Icons.person, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.neonGreen
                  : _isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[500],
              size: 24,
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withOpacity(0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    final isActive = _activeTab == 2;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = 2),
      child: Transform.translate(
        offset: const Offset(0, -32),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.neonGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withOpacity(isActive ? 0.6 : 0.4),
                blurRadius: isActive ? 24 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.add_circle,
            color: AppColors.textDark,
            size: isActive ? 28 : 24,
          ),
        ),
      ),
    );
  }
}
