# Stateless vs Stateful Widgets - SafeStride Implementation

[← Back to Main README](../README.md)

## Project Overview

This implementation demonstrates the difference between **Stateless** and **Stateful** widgets in Flutter through a practical feature: **Route Safety Rating System**. This feature adds real value to the SafeStride app by allowing users to submit safety ratings for routes.

---

## What Are Stateless and Stateful Widgets?

### Stateless Widget
A **StatelessWidget** does not store any mutable state — once built, it does not change until rebuilt by its parent. Use it for static UI components that remain constant.

**When to use:**
- Display static content (headers, labels, icons)
- Information that doesn't change based on user interaction
- Pure presentational components

### Stateful Widget
A **StatefulWidget** maintains internal state that can change during the app's lifecycle. It can update its UI dynamically in response to user actions, animations, or data changes.

**When to use:**
- Interactive elements (buttons, forms, toggles)
- Content that changes based on user input
- Real-time updates and animations

---

## Implementation in SafeStride

### 1. SafetyInfoDisplay (Stateless Widget)

This widget displays static route safety information - it doesn't change internally, only when new data is passed from parent.

```dart
class SafetyInfoDisplay extends StatelessWidget {
  final RouteModel route;
  final bool isDarkMode;

  const SafetyInfoDisplay({
    Key? key,
    required this.route,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Static display - no internal state changes
    return Container(
      // Display route safety information
    );
  }
}
```

**Key characteristics:**
- No `setState()` needed
- Receives all data via constructor parameters
- Rebuilds only when parent passes new data

### 2. SafetyRatingForm (Stateful Widget)

This widget allows users to submit safety ratings - it manages internal state for selected rating, comments, and submission status.

```dart
class SafetyRatingForm extends StatefulWidget {
  final RouteModel route;
  final Function(bool) onRatingSubmitted;
  final bool isDarkMode;

  @override
  State<SafetyRatingForm> createState() => _SafetyRatingFormState();
}

class _SafetyRatingFormState extends State<SafetyRatingForm> {
  int selectedRating = 0;
  String comment = '';
  bool isSubmitting = false;

  void _submitRating() {
    setState(() {
      isSubmitting = true;
    });
    // Handle submission...
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic UI with internal state
  }
}
```

**Key characteristics:**
- Uses `setState()` to update UI
- Manages internal state (selectedRating, isSubmitting)
- Reacts to user interactions

---

## Widget Tree Hierarchy

```
MaterialApp
 └── RouteDetailScreen (Stateless)
     └── RouteSafetyRatingScreen (Stateful)
         ├── SafetyInfoDisplay (Stateless)
         │   ├── Container
         │   │   └── Column
         │   │       ├── Row
         │   │       │   ├── Container (safety indicator)
         │   │       │   └── Text
         │   │       └── Row
         │   │           ├── Expanded (_buildStatCard)
         │   │           ├── Expanded (_buildStatCard)
         │   │           └── Expanded (_buildStatCard)
         └── SafetyRatingForm (Stateful)
             ├── Container
             │   └── Column
             │       ├── Row
             │       ├── Wrap (ChoiceChips - interactive)
             │       ├── TextFormField (interactive)
             │       └── ElevatedButton (interactive)
             └── [State managed: selectedRating, isSubmitting]
```

---

## How State Updates Work

### Initial State
- User views route details
- SafetyInfoDisplay shows static safety data
- SafetyRatingForm shows rating options (default: none selected)

### After Interaction
1. User selects a rating (e.g., "Safe")
2. `setState()` is called with new `selectedRating`
3. Flutter rebuilds only the `ChoiceChip` that changed
4. Submit button becomes enabled

### After Submission
1. User taps "Submit Rating"
2. `setState()` sets `isSubmitting = true`
3. Loading indicator appears
4. After 2 seconds, success message shows

---

## Screenshots

### Before Interaction (Initial State)
- Static safety info displayed
- Rating options available but none selected
- Submit button disabled

### After Interaction
- Selected rating highlighted
- Submit button enabled
- Loading state during submission
- Success message after completion

---

## Reflection

### How do Stateful widgets make Flutter apps dynamic?

Stateful widgets enable Flutter apps to be truly interactive and responsive. They allow:
- Real-time UI updates without manual redrawing
- User input handling (forms, buttons, gestures)
- Animation control
- Data-driven interfaces

### Why is it important to separate static and reactive parts of UI?

1. **Performance**: Stateless widgets don't rebuild unnecessarily
2. **Maintainability**: Clear separation of concerns
3. **Reusability**: Stateless widgets are easier to reuse
4. **Testability**: Stateless widgets are simpler to test
5. **Efficiency**: Flutter's diffing algorithm works best with granular widgets

---

## Integration with SafeStride

This feature is integrated into the existing Route Detail screen:
- **Button**: "Rate This Route" button added to RouteDetailScreen
- **Navigation**: Opens RouteSafetyRatingScreen with route data
- **Design**: Follows existing SafeStride design system
- **Theme**: Supports both light and dark modes

---

## Video Demo

[Add video link here - Google Drive/Loom/YouTube]

---

## Files Modified/Created

| File | Description |
|------|-------------|
| `lib/screens/route_safety_screen.dart` | New file with Stateless & Stateful widgets |
| `lib/screens/route_detail_screen.dart` | Added navigation to safety rating screen |

---

[← Back to Main README](../README.md)