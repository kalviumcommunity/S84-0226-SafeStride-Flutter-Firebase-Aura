import 'package:flutter/material.dart';

/// Sprint #2: Responsive UI Implementation
/// 
/// This screen demonstrates:
/// - MediaQuery for screen size detection
/// - LayoutBuilder for adaptive layout rendering
/// - Single column ListView for phones (width <= 600)
/// - Two-column GridView for tablets (width > 600)
/// - Proper use of Expanded, Flexible widgets
/// - Material3 design with no overflow errors
class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery: Get screen dimensions for responsiveness
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    // Responsive breakpoint: width > 600 = tablet/desktop
    final isTablet = screenWidth > 600;
    
    // Adaptive padding based on screen size
    final horizontalPadding = isTablet ? 32.0 : 16.0;
    final verticalPadding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeStride - Responsive UI'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      // LayoutBuilder: Provides constraints for adaptive rendering
      body: LayoutBuilder(
        builder: (context, constraints) {
          // constraints.maxWidth and maxHeight available here
          return Column(
            children: [
              // Header Section - Flexible takes available space
              _buildHeader(
                context,
                isTablet: isTablet,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                horizontalPadding: horizontalPadding,
              ),
              
              // Main Content Section - Expanded prevents overflow
              Expanded(
                child: _buildMainContent(
                  context,
                  isTablet: isTablet,
                  constraints: constraints,
                  horizontalPadding: horizontalPadding,
                  verticalPadding: verticalPadding,
                ),
              ),
              
              // Footer Section - Fixed height, safe area aware
              _buildFooter(
                context,
                isTablet: isTablet,
                horizontalPadding: horizontalPadding,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Header: Displays screen info and welcome message
  Widget _buildHeader(
    BuildContext context, {
    required bool isTablet,
    required double screenWidth,
    required double screenHeight,
    required double horizontalPadding,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to SafeStride',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          // MediaQuery info display
          Text(
            'Screen: ${screenWidth.toInt()}×${screenHeight.toInt()} • ${isTablet ? 'Tablet' : 'Phone'} Mode',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  /// Main Content: Adaptive layout - ListView for phones, GridView for tablets
  Widget _buildMainContent(
    BuildContext context, {
    required bool isTablet,
    required BoxConstraints constraints,
    required double horizontalPadding,
    required double verticalPadding,
  }) {
    // Sample data for demonstration
    final items = List.generate(
      8,
      (index) => {
        'title': 'Feature ${index + 1}',
        'description': 'Responsive layout demonstration item',
        'icon': _getIconForIndex(index),
      },
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: isTablet
          ? _buildTabletLayout(context, items, constraints)
          : _buildPhoneLayout(context, items),
    );
  }

  /// Phone Layout: Single column ListView (width <= 600)
  Widget _buildPhoneLayout(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) {
    return ListView.builder(
      itemCount: items.length,
      // Prevent list bounce at edges for cleaner UX
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                item['icon'] as IconData,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(item['description'] as String),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  /// Tablet Layout: Two-column GridView (width > 600)
  Widget _buildTabletLayout(
    BuildContext context,
    List<Map<String, dynamic>> items,
    BoxConstraints constraints,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two columns for tablets
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5, // Width/Height ratio for cards
      ),
      itemCount: items.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 3,
          child: InkWell(
            onTap: () {
              // Placeholder for navigation/interaction
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tapped: ${item['title']}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  // Flexible prevents text overflow
                  Flexible(
                    child: Text(
                      item['title'] as String,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      item['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Footer: Action button with safe area padding
  Widget _buildFooter(
    BuildContext context, {
    required bool isTablet,
    required double horizontalPadding,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Expanded ensures buttons fill available space
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Placeholder for Firebase sync action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔥 Firebase Synced Successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.sync),
                label: Text(isTablet ? 'Sync with Firebase' : 'Sync'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: isTablet ? 1 : 2,
              child: FilledButton.icon(
                onPressed: () {
                  // Placeholder for continue action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Continue action triggered'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continue'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper: Get icon for each item
  IconData _getIconForIndex(int index) {
    const icons = [
      Icons.security,
      Icons.notifications,
      Icons.location_on,
      Icons.settings,
      Icons.people,
      Icons.dashboard,
      Icons.analytics,
      Icons.help_outline,
    ];
    return icons[index % icons.length];
  }
}
