import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// OriginOS glassmorphism card with ~20px backdrop blur, ~10-15% white opacity,
/// rounded corners (16-24px), soft top-edge glow, and subtle drop shadow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? surfaceColor;
  final Color? borderColor;
  final Gradient? borderGradient;
  final List<BoxShadow>? shadows;
  final double blurSigma;
  final double? width;
  final double? height;
  final bool hasTopGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
    this.onTap,
    this.surfaceColor,
    this.borderColor,
    this.borderGradient,
    this.shadows,
    this.blurSigma = 20.0,
    this.width,
    this.height,
    this.hasTopGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSurfaceColor = surfaceColor ?? AppColors.glassSurface;
    final effectiveBorderGradient = borderGradient ??
        (hasTopGlow
            ? AppColors.glassBorderGradient
            : LinearGradient(
                colors: [
                  borderColor ?? AppColors.glassBorder,
                  borderColor ?? AppColors.glassBorderSubtle,
                ],
              ));

    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: effectiveSurfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );

    // Apply backdrop blur filter
    Widget blurred = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );

    // Gradient border stroke wrapper (simulates OriginOS luminous edge)
    Widget bordered = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ??
            [
              const BoxShadow(
                color: Color(0x55000000),
                blurRadius: 24,
                spreadRadius: -2,
                offset: Offset(0, 10),
              ),
              if (hasTopGlow)
                const BoxShadow(
                  color: Color(0x0F00E5FF),
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset: Offset(0, -2),
                ),
            ],
      ),
      child: CustomPaint(
        painter: _GlassBorderPainter(
          borderRadius: borderRadius,
          gradient: effectiveBorderGradient,
          strokeWidth: 1.2,
        ),
        child: blurred,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.primaryCyan.withOpacity(0.12),
          highlightColor: Colors.white.withOpacity(0.05),
          onTap: onTap,
          child: bordered,
        ),
      );
    }

    return bordered;
  }
}

/// Custom painter to draw a crisp gradient stroke border along rounded rect
class _GlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final Gradient gradient;
  final double strokeWidth;

  _GlassBorderPainter({
    required this.borderRadius,
    required this.gradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradient != gradient;
  }
}
