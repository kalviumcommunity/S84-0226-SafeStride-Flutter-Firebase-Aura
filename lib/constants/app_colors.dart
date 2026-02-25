import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Landing Page Theme
  static const Color primaryGreen = Color(0xFF6EEB5F); // Primary Green
  static const Color hoverGreen = Color(0xFF5EDC4A);   // Hover Green
  static const Color neonGreen = Color(0xFF7DF258);
  static const Color darkGreen = Color(0xFF4ADE80);
  
  // Background Colors - Soft bluish-grey
  static const Color bgLight = Color(0xFFF5F7FA);      // Light bg
  static const Color bgDark = Color(0xFFE8EEF5);       // Dark bg (gradient end)
  static const Color cardBg = Color(0xFFF8FAFB);       // Card background
  
  // Blue tones
  static const Color darkBlue = Color(0xFF0A1628);
  static const Color mediumBlue = Color(0xFF1A2A42);
  static const Color lightBlue = Color(0xFF0F1F3A);
  static const Color skyBlue = Color(0xFF3B82F6);
  static const Color primaryBlue = Color(0xFF1E40AF);
  
  // Safety Colors
  static const Color safetyHigh = Color(0xFF7DF258);
  static const Color safetyMedium = Color(0xFFFBBF24);
  static const Color safetyLow = Color(0xFFEF4444);
  
  // Background Colors
  static const Color lightBackground = Color(0xFFE8F0FE);
  static const Color lightGray = Color(0xFFF5F7FA);
  static const Color white = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textDark = Color(0xFF0A1628);
  static const Color textGray = Color(0xFF6B7280);
  static const Color textLightGray = Color(0xFF9CA3AF);
  
  static Color getSafetyColor(int safety) {
    if (safety >= 85) return safetyHigh;
    if (safety >= 70) return safetyMedium;
    return safetyLow;
  }
  
  // Landing Page Gradients
  static LinearGradient get landingBgGradient => const LinearGradient(
    colors: [bgLight, bgDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get primaryGreenGradient => const LinearGradient(
    colors: [primaryGreen, hoverGreen],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static LinearGradient get neonGradient => const LinearGradient(
    colors: [neonGreen, darkGreen],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static LinearGradient get blueGradient => const LinearGradient(
    colors: [primaryBlue, skyBlue, neonGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
