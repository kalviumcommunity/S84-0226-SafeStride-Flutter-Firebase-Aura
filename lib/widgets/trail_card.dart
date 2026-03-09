import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/route_model.dart';

// ── Data model ────────────────────────────────────────────────────────────────

/// Represents a single trail point shown on the map and in the card list.
class TrailSpot {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final String distance;
  final String lighting;
  final String crowd;
  final int safety;
  final String emoji;
  final String category;

  const TrailSpot({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.distance,
    required this.lighting,
    required this.crowd,
    required this.safety,
    required this.emoji,
    required this.category,
  });

  /// Convert to [RouteModel] so existing route-detail navigation works.
  RouteModel toRouteModel() => RouteModel(
        id: id,
        name: name,
        category: category,
        distance: distance,
        safety: safety,
        lighting: lighting,
        traffic: 'Low',
        crowd: crowd,
        reviews: 0,
        rating: safety / 20.0,
        image: name,
        emoji: emoji,
      );
}

// ── Trail card widget ─────────────────────────────────────────────────────────

/// A single horizontally-scrollable card in the bottom trail panel.
/// Highlights with a green border when [isSelected] is true.
class TrailCard extends StatelessWidget {
  final TrailSpot trail;
  final bool isSelected;
  final bool isDarkMode;

  /// Called when the card body is tapped (animates camera to this trail).
  final VoidCallback onTap;

  /// Called when "View Route Details" button is pressed.
  final VoidCallback onViewDetails;

  const TrailCard({
    Key? key,
    required this.trail,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final safetyColor = AppColors.getSafetyColor(trail.safety);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        // Width is fixed so the scroll-to-index math works
        width: 252,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.mediumBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.neonGreen : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.neonGreen.withOpacity(0.25)
                  : Colors.black.withOpacity(isDarkMode ? 0.28 : 0.07),
              blurRadius: isSelected ? 18 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row ──────────────────────────────────────────────────
            Row(
              children: [
                Text(trail.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trail.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Safety badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: safetyColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield, size: 11, color: safetyColor),
                      const SizedBox(width: 2),
                      Text(
                        '${trail.safety}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: safetyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Stat chips ───────────────────────────────────────────────────
            Row(
              children: [
                _chip(Icons.straighten, trail.distance, isDarkMode),
                const SizedBox(width: 6),
                _chip(Icons.wb_sunny_outlined, trail.lighting, isDarkMode),
                const SizedBox(width: 6),
                _chip(Icons.people_outline, trail.crowd, isDarkMode),
              ],
            ),

            const SizedBox(height: 12),

            // ── View details button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppColors.neonGreen
                      : (isDarkMode
                          ? AppColors.lightBlue
                          : const Color(0xFFEEF2FF)),
                  foregroundColor: isSelected
                      ? AppColors.textDark
                      : (isDarkMode ? Colors.white : AppColors.primaryBlue),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Route Details',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact icon + label chip used for Distance / Lighting / Crowd.
  Widget _chip(IconData icon, String label, bool dark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: dark
              ? AppColors.lightBlue
              : AppColors.neonGreen.withOpacity(0.06),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 11, color: dark ? Colors.grey[400] : Colors.grey[600]),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: dark ? Colors.grey[300] : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
