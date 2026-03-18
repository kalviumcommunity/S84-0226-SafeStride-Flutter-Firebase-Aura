import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/app_colors.dart';
import '../widgets/location_step.dart';

class AddRoutePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<List<LatLng>>? onLocationStepCompleted;
  final VoidCallback? onBack;
  final VoidCallback? onContinueToMedia;

  const AddRoutePage({
    super.key,
    required this.isDarkMode,
    this.onLocationStepCompleted,
    this.onBack,
    this.onContinueToMedia,
  });

  @override
  State<AddRoutePage> createState() => _AddRoutePageState();
}

class _AddRoutePageState extends State<AddRoutePage> {
  List<LatLng> routePoints = <LatLng>[];

  void _handleRoutePointsChanged(List<LatLng> points) {
    setState(() {
      routePoints = points;
    });
  }

  void _handleContinue() {
    if (routePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please mark at least one route point before continuing.',
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    widget.onLocationStepCompleted?.call(routePoints);

    if (widget.onContinueToMedia != null) {
      widget.onContinueToMedia!.call();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Route points captured. Media step can be connected next.',
        ),
        backgroundColor: widget.isDarkMode
            ? AppColors.mediumBlue
            : AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!.call();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? AppColors.darkBlue
          : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _StepProgressIndicator(isDarkMode: widget.isDarkMode),
              const SizedBox(height: 20),
              Expanded(
                child: LocationStep(
                  isDarkMode: widget.isDarkMode,
                  routePoints: routePoints,
                  onRoutePointsChanged: _handleRoutePointsChanged,
                  onContinue: _handleContinue,
                  onBack: _handleBack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepProgressIndicator extends StatelessWidget {
  final bool isDarkMode;

  const _StepProgressIndicator({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _stepCircle(number: '1', isActive: false, isCompleted: true),
            _line(isFilled: true),
            _stepCircle(number: '2', isActive: true, isCompleted: false),
            _line(isFilled: false),
            _stepCircle(number: '3', isActive: false, isCompleted: false),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _stepLabel('Details', active: false),
            _stepLabel('Location', active: true),
            _stepLabel('Media', active: false),
          ],
        ),
      ],
    );
  }

  Widget _stepCircle({
    required String number,
    required bool isActive,
    required bool isCompleted,
  }) {
    final Color background = isActive || isCompleted
        ? AppColors.neonGreen
        : (isDarkMode ? AppColors.mediumBlue : Colors.white);

    final Color textColor = isActive || isCompleted
        ? AppColors.textDark
        : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600);

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.neonGreen.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
        ),
      ),
    );
  }

  Widget _line({required bool isFilled}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 4,
        decoration: BoxDecoration(
          color: isFilled
              ? AppColors.neonGreen
              : (isDarkMode ? AppColors.mediumBlue : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _stepLabel(String label, {required bool active}) {
    final Color color = active
        ? (isDarkMode ? AppColors.neonGreen : AppColors.primaryBlue)
        : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600);

    return Text(
      label,
      style: TextStyle(
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        color: color,
      ),
    );
  }
}
