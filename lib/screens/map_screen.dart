import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../constants/app_colors.dart';
import '../constants/mock_data.dart';
import '../config/routes.dart';

class MapScreen extends StatefulWidget {
  final Function(RouteModel) onRouteSelect;
  final bool isDarkMode;

  const MapScreen({
    Key? key,
    required this.onRouteSelect,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String mode = 'runner';
  int selectedRouteId = 1;
  
  // Filter state
  Set<String> selectedSafetyLevels = {'High', 'Medium', 'Low'};
  String selectedDistanceRange = 'All';

  RouteModel? get selectedRoute =>
      MockData.routes.firstWhere((r) => r.id == selectedRouteId);
  
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Routes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Safety Level Filter
              Text(
                'Safety Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: ['High', 'Medium', 'Low'].map((level) {
                  final isSelected = selectedSafetyLevels.contains(level);
                  return FilterChip(
                    label: Text(level),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        if (selected) {
                          selectedSafetyLevels.add(level);
                        } else {
                          selectedSafetyLevels.remove(level);
                        }
                      });
                      setState(() {});
                    },
                    backgroundColor: widget.isDarkMode ? AppColors.lightBlue : Colors.grey[100],
                    selectedColor: AppColors.neonGreen.withOpacity(0.3),
                    checkmarkColor: AppColors.textDark,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.textDark
                          : widget.isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? BorderSide(color: AppColors.neonGreen, width: 2)
                          : BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Distance Range Filter
              Text(
                'Distance Range',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ['All', '0-5 km', '5-10 km', '10+ km'].map((range) {
                  final isSelected = selectedDistanceRange == range;
                  return ChoiceChip(
                    label: Text(range),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => selectedDistanceRange = range);
                        setState(() {});
                      }
                    },
                    backgroundColor: widget.isDarkMode ? AppColors.lightBlue : Colors.grey[100],
                    selectedColor: AppColors.neonGreen.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.textDark
                          : widget.isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? BorderSide(color: AppColors.neonGreen, width: 2)
                          : BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Filters applied: ${selectedSafetyLevels.length} safety levels, $selectedDistanceRange',
                        ),
                        backgroundColor: widget.isDarkMode ? AppColors.mediumBlue : AppColors.primaryBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? AppColors.darkBlue
          : AppColors.lightBackground,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDarkMode
                    ? [AppColors.lightBlue, Colors.transparent]
                    : [AppColors.lightBackground, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.only(left: 24, right: 24, top: 64, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TrailSync',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sync Your Stride.',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.filter_list,
                                color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                size: 20,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.neonGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.neonGreen.withOpacity(0.6),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Mode Toggle
                Container(
                  decoration: BoxDecoration(
                    color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeButton('runner', '🏃', 'Runner'),
                      _buildModeButton('cyclist', '🚴', 'Cyclist'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Map Area
          Expanded(
            child: Stack(
              children: [
                // Map Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isDarkMode
                          ? [AppColors.lightBlue, AppColors.mediumBlue, AppColors.darkBlue]
                          : [const Color(0xFFDBEAFE), const Color(0xFFE0E7FF), const Color(0xFFF0F9FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CustomPaint(
                    painter: MapPainter(
                      isDarkMode: widget.isDarkMode,
                      routes: MockData.routes,
                    ),
                    size: Size.infinite,
                  ),
                ),
                // Route Markers
                ...MockData.routes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final route = entry.value;
                  return Positioned(
                    top: 100.0 + (index * 150.0),
                    left: 80.0 + (index * 60.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.routeDetail,
                          arguments: RouteDetailArguments(
                            route: route,
                            isDarkMode: widget.isDarkMode,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            route.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.getSafetyColor(route.safety),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.getSafetyColor(route.safety).withOpacity(0.6),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                // Compass Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? AppColors.mediumBlue : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.navigation,
                      color: widget.isDarkMode ? AppColors.neonGreen : AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
                // Bottom Sheet
                if (selectedRoute != null)
                  Positioned(
                    bottom: 112,
                    left: 24,
                    right: 24,
                    child: _buildRouteCard(selectedRoute!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String modeValue, String emoji, String label) {
    final isActive = mode == modeValue;
    return GestureDetector(
      onTap: () => setState(() => mode = modeValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.neonGradient : null,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.neonGreen.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppColors.textDark
                    : widget.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(RouteModel route) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: widget.isDarkMode
            ? const LinearGradient(
                colors: [AppColors.mediumBlue, AppColors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: widget.isDarkMode ? null : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDarkMode
              ? AppColors.neonGreen.withOpacity(0.1)
              : AppColors.neonGreen.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDarkMode ? 0.4 : 0.12),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(route.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            route.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.isDarkMode
                                ? AppColors.neonGreen.withOpacity(0.2)
                                : AppColors.neonGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            route.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.isDarkMode ? AppColors.neonGreen : AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          route.distance,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.getSafetyColor(route.safety).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getSafetyColor(route.safety).withOpacity(0.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield,
                      color: AppColors.getSafetyColor(route.safety),
                      size: 24,
                    ),
                    Text(
                      '${route.safety}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getSafetyColor(route.safety),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Lighting', route.lighting)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Traffic', route.traffic)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Crowd', route.crowd)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.routeDetail,
                  arguments: RouteDetailArguments(
                    route: route,
                    isDarkMode: widget.isDarkMode,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: AppColors.textDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: AppColors.neonGreen.withOpacity(0.3),
              ),
              child: const Text(
                'View Route Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppColors.lightBlue : AppColors.neonGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final bool isDarkMode;
  final List<RouteModel> routes;

  MapPainter({required this.isDarkMode, required this.routes});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid pattern
    final gridPaint = Paint()
      ..color = (isDarkMode
              ? AppColors.neonGreen.withOpacity(0.03)
              : AppColors.primaryBlue.withOpacity(0.05))
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw paths for routes
    final path1 = Path();
    path1.moveTo(50, size.height * 0.5);
    path1.quadraticBezierTo(
      150,
      size.height * 0.33,
      250,
      size.height * 0.42,
    );

    final routePaint1 = Paint()
      ..color = AppColors.getSafetyColor(routes.isNotEmpty ? routes[0].safety : 95)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path1, routePaint1);

    // Draw more paths
    if (routes.length > 1) {
      final path2 = Path();
      path2.moveTo(80, size.height * 0.25);
      path2.quadraticBezierTo(
        200,
        size.height * 0.17,
        300,
        size.height * 0.3,
      );

      final routePaint2 = Paint()
        ..color = AppColors.getSafetyColor(routes[1].safety)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path2, routePaint2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
