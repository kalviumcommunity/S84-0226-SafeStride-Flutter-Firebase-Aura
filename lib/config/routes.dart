import 'package:flutter/material.dart';
import '../screens/route_detail_screen.dart';
import '../screens/navigation_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../models/route_model.dart';
import '../models/user_model.dart';
import '../screens/main_screen.dart';
import '../screens/landing_page.dart';
import '../screens/login/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/add_route_screen.dart';
import '../services/routing_service.dart';

/// Route names as constants for type safety and maintainability
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route constants
  static const String landing = '/landing';
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String map = '/map';
  static const String discover = '/discover';
  static const String addRoute = '/add-route';
  static const String alerts = '/alerts';
  static const String profile = '/profile';
  static const String routeDetail = '/route-detail';
  static const String navigation = '/navigation';
  static const String editProfile = '/edit-profile';
}

/// Arguments class for type-safe argument passing
class RouteDetailArguments {
  final RouteModel route;

  const RouteDetailArguments({required this.route});
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
      case AppRoutes.landing:
        return MaterialPageRoute(
          builder: (_) => const LandingPage(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );

      case AppRoutes.addRoute:
        return MaterialPageRoute(
          builder: (_) => const AddRouteScreen(),
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
            ),
            settings: settings,
          );
        }
        return _errorRoute(settings);

      case AppRoutes.navigation:
        if (settings.arguments is RouteModel) {
          final route = settings.arguments as RouteModel;
          return MaterialPageRoute(
            builder: (_) =>
                NavigationScreen(route: route, profile: RoutingProfile.foot),
            settings: settings,
          );
        }
        return _errorRoute(settings);

      case AppRoutes.editProfile:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final userModel = args['userModel'] as UserModel;
          return MaterialPageRoute(
            builder: (_) =>
                EditProfileScreen(userModel: userModel),
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
        appBar: AppBar(title: const Text('Error'), backgroundColor: Colors.red),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
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
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
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
