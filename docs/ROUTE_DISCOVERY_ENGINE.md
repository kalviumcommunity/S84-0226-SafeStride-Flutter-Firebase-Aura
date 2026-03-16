# Route Discovery Engine

This document provides a low-level design overview of the route discovery, filtering, and sorting engine in SafeStride.

## Overview

The `DiscoveryEngine` is a core service that manages how routes are presented to the user. It ensures that users can find the safest and most relevant routes based on their preferences, location, and community feedback.

## Key Components

### 1. Filtering Logic
The discovery engine supports two main types of filtering:
- **Search Query Filtering**: Users can search for routes by name or category (e.g., "Park", "Run", "Trail"). This is case-insensitive.
- **Safety Score Filtering**: A critical feature of SafeStride. Users can set a minimum safety threshold (e.g., 80%+, 90%+). This ensures that only routes with high community-validated safety scores are displayed.

### 2. Sorting Strategies
The engine supports multiple sorting strategies to help users prioritize their discovery:
- **Trending**: Sorted by the number of reviews (most popular routes first).
- **Safest**: Sorted by the safety percentage score (highest safety first).
- **Top Rated**: Sorted by the average user rating (stars).
- **Nearby**: Sorted by physical distance from the user's current location, correctly handling both meters (m) and kilometers (km).

## Architecture

The logic is decoupled from the UI to ensure testability and maintainability:
- **`lib/services/discovery_engine.dart`**: Contains pure Dart logic for filtering and sorting.
- **`lib/screens/discover_screen.dart`**: Manages the UI state and calls the `DiscoveryEngine` to get the final list of routes.
- **`test/discovery_engine_test.dart`**: Comprehensive unit tests covering all filtering and sorting scenarios.

## UI Implementation

### Safety Filter Row
The discovery screen includes a horizontal filter bar using `ChoiceChip` widgets. This allows users to quickly toggle between safety thresholds:
- **All**: Shows all routes.
- **Safe (80%+)**: Filters routes with a safety score of 80 or higher.
- **Very Safe (90%+)**: Filters routes with a safety score of 90 or higher.
- **Safest (95%+)**: Filters routes with a safety score of 95 or higher.

### Empty State Handling
When no routes match the current filters, the app displays a helpful empty state that:
- Informs the user that no results were found.
- Suggests adjusting the filters.
- Provides a "Clear all filters" button to reset the search and safety settings.

## Data Model Integration
The discovery engine works directly with the `RouteModel`, leveraging fields such as:
- `safety` (int)
- `rating` (double)
- `reviews` (int)
- `distance` (String)

---
[← Back to Main README](../README.md)
