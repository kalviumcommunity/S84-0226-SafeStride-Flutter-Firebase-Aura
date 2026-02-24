# 🚀 SafeStride Navigation - Quick Reference

## Essential Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check for errors
flutter analyze

# Format code
flutter format .
```

---

## 🎯 Quick Navigation Examples

### Navigate to Route Detail
```dart
Navigator.pushNamed(
  context,
  AppRoutes.routeDetail,
  arguments: RouteDetailArguments(
    route: selectedRoute,
    isDarkMode: isDarkMode,
  ),
);
```

### Go Back
```dart
Navigator.pop(context);
```

### Go Home (Clear Stack)
```dart
Navigator.pushNamedAndRemoveUntil(
  context,
  AppRoutes.home,
  (route) => false,
);
```

---

## 📋 Available Routes

```dart
AppRoutes.home          // '/'
AppRoutes.routeDetail   // '/route-detail'
```

---

## 🎨 Adding New Routes

1. Add route constant:
```dart
// In lib/config/routes.dart
static const String newScreen = '/new-screen';
```

2. Add route handler:
```dart
case AppRoutes.newScreen:
  return MaterialPageRoute(
    builder: (context) => NewScreen(),
    settings: settings,
  );
```

3. Navigate:
```dart
Navigator.pushNamed(context, AppRoutes.newScreen);
```

---

## 🔧 Common Patterns

### With Return Value
```dart
// Navigate and wait for result
final result = await Navigator.pushNamed(
  context,
  AppRoutes.settings,
);

if (result == true) {
  // Handle result
}
```

### Replace Current Route
```dart
Navigator.pushReplacementNamed(
  context,
  AppRoutes.login,
);
```

---

## 🐛 Troubleshooting

### "Route not found" Error
- Check route is defined in `AppRoutes` constants
- Verify route case is added in `generateRoute`
- Ensure route name matches exactly (case-sensitive)

### Arguments Not Passed
- Verify arguments class is defined
- Check type casting is correct
- Use `is` operator before casting

### Back Button Not Working
- Ensure `Navigator.pop(context)` is called
- Check if routes are properly stacked
- Verify MaterialApp has `onGenerateRoute`

---

## ✅ Best Practices

- ✅ Always use `AppRoutes` constants (never hardcode strings)
- ✅ Use argument classes for type safety
- ✅ Handle null cases when retrieving arguments
- ✅ Test navigation on both Android and iOS
- ✅ Keep routes.dart updated with all routes
- ✅ Document complex navigation flows

---

## 📱 Screen Structure

```
Home (MainScreen)
├── Tab 0: MapScreen
├── Tab 1: DiscoverScreen
├── Tab 2: AddRouteScreen
├── Tab 3: AlertsScreen
└── Tab 4: ProfileScreen

Navigation Stack:
MainScreen → RouteDetailScreen
```

---

**For detailed documentation, see:** [NAVIGATION_IMPLEMENTATION.md](NAVIGATION_IMPLEMENTATION.md)
