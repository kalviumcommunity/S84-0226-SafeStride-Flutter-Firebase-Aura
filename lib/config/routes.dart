import 'package:flutter/material.dart';
import '../screens/route_detail_screen.dart';
import '../models/route_model.dart';
import '../main.dart';

/// Route names as constants for type safety and maintainability
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route constants
  static const String home = '/';
  static const String map = '/map';
  static const String discover = '/discover';
  static const String addRoute = '/add-route';
  static const String alerts = '/alerts';
  static const String profile = '/profile';
  static const String routeDetail = '/route-detail';
}

/// Arguments class for type-safe argument passing
class RouteDetailArguments {
  final RouteModel route;
  final bool isDarkMode;

  const RouteDetailArguments({
    required this.route,
    required this.isDarkMode,
  });
}

class ScreenArguments {
  final bool isDarkMode;
  final Function(RouteModel)? onRouteSelect;
  final VoidCallback? onToggleDarkMode;
  final VoidCallback? onBack;

  const ScreenArguments({
    required this.isDarkMode,
    this.onRouteSelect,
    this.onToggleDarkMode,
    this.onBack,
  });
}

/// Centralized route configuration
class RouteGenerator {
  // Private constructor
  RouteGenerator._();

  /// Generates routes based on RouteSettings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );

      case AppRoutes.routeDetail:
        // Extract arguments with type safety
        if (settings.arguments is RouteDetailArguments) {
          final args = settings.arguments as RouteDetailArguments;
          return MaterialPageRoute(
            builder: (context) => RouteDetailScreen(
              route: args.route,
              onBack: () => Navigator.of(context).pop(),
              isDarkMode: args.isDarkMode,
            ),
            settings: settings,
          );
        }
        return _errorRoute(settings);

      default:
        return _errorRoute(settings);
    }
  }

  /// Error route for undefined routes
  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Route not found: ${settings.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                ),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }
}
