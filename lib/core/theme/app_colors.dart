import 'package:flutter/material.dart';

/// OriginOS inspired visual palette for RoomFit
/// Features deep dark space canvas (#0A0A0F), translucent glass surfaces,
/// vivid electric cyan/blue primary accents, and distinct status color tokens.
class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFF0A0A0F);
  static const Color backgroundSurface = Color(0xFF101018);
  static const Color backgroundElevated = Color(0xFF161622);

  // Primary Action Accents (Electric Cyan / Neon Blue)
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color primaryBlue = Color(0xFF0077FE);
  static const Color primaryPurple = Color(0xFF7B2CBF);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00F0FF),
      Color(0xFF0066FF),
    ],
  );

  static const LinearGradient electricCyanGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x6600F0FF),
      Color(0x0000F0FF),
    ],
  );

  // Status Accents
  static const Color statusGreen = Color(0xFF00E676); // Fits comfortably
  static const Color statusAmber = Color(0xFFFFB300); // Tight / low-confidence / packaging
  static const Color statusRed = Color(0xFFFF3B30);   // Won't fit / not found / collision

  static const Color statusGreenBg = Color(0x2600E676);
  static const Color statusAmberBg = Color(0x26FFB300);
  static const Color statusRedBg = Color(0x26FF3B30);

  // Glass Surface Panels (10-15% opacity white)
  static const Color glassSurface = Color(0x1AFFFFFF);      // ~10% white
  static const Color glassSurfaceMedium = Color(0x24FFFFFF);// ~14% white
  static const Color glassSurfaceElevated = Color(0x2BFFFFFF);// ~17% white
  static const Color glassBorder = Color(0x2EFFFFFF);       // ~18% subtle white stroke
  static const Color glassBorderSubtle = Color(0x1FFFFFFF); // ~12% stroke

  // Glass Top-Edge Glow Gradient (OriginOS refractive light reflection)
  static const LinearGradient glassBorderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x80FFFFFF),
      Color(0x1AFFFFFF),
      Color(0x05FFFFFF),
    ],
  );

  static const LinearGradient cyanBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xCC00F0FF),
      Color(0x400077FE),
      Color(0x1A00F0FF),
    ],
  );

  // Text & Typography colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B7C9);
  static const Color textTertiary = Color(0xFF6E768E);
  static const Color textMuted = Color(0xFF4A5164);

  // Shadows
  static const Color shadowColor = Color(0x66000000);
  static const Color cyanShadow = Color(0x4D00E5FF);
}
