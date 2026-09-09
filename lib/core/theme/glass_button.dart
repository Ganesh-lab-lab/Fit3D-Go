import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

enum GlassButtonVariant {
  primary,   // Vivid electric cyan with glowing border & subtle glow
  secondary, // Frosted glass with subtle white stroke
  danger,    // Amber/Red alert action
  ghost,     // Minimalist transparent glass
}

class GlassButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? label;
  final IconData? icon;
  final GlassButtonVariant variant;
  final double height;
  final double? width;
  final double borderRadius;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;

  const GlassButton({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.icon,
    this.variant = GlassButtonVariant.primary,
    this.height = 52.0,
    this.width,
    this.borderRadius = 16.0,
    this.isLoading = false,
    this.padding,
  }) : assert(child != null || label != null, 'Either child or label must be provided');

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animController.reverse();
  }

  void _onTapCancel() {
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    Color fillColor;
    Gradient? fillGradient;
    Gradient borderGradient;
    Color textColor;
    List<BoxShadow> shadows = [];

    switch (widget.variant) {
      case GlassButtonVariant.primary:
        fillColor = const Color(0x2400F0FF); // Translucent electric cyan glass fill
        fillGradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x3800F0FF),
            Color(0x220066FF),
          ],
        );
        borderGradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00F0FF),
            Color(0x8800D2FF),
            Color(0x440077FE),
          ],
        );
        textColor = AppColors.primaryCyan;
        if (isEnabled) {
          shadows = const [
            BoxShadow(
              color: Color(0x5500F0FF),
              blurRadius: 18,
              spreadRadius: -2,
              offset: Offset(0, 4),
            ),
          ];
        }
        break;

      case GlassButtonVariant.secondary:
        fillColor = AppColors.glassSurfaceMedium;
        fillGradient = null;
        borderGradient = AppColors.glassBorderGradient;
        textColor = AppColors.textPrimary;
        shadows = const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ];
        break;

      case GlassButtonVariant.danger:
        fillColor = const Color(0x2BFF3B30);
        fillGradient = const LinearGradient(
          colors: [Color(0x40FF3B30), Color(0x20FF3B30)],
        );
        borderGradient = const LinearGradient(
          colors: [Color(0xFFFF3B30), Color(0x66FF3B30)],
        );
        textColor = const Color(0xFFFF5252);
        shadows = const [
          BoxShadow(
            color: Color(0x44FF3B30),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ];
        break;

      case GlassButtonVariant.ghost:
        fillColor = Colors.transparent;
        fillGradient = null;
        borderGradient = const LinearGradient(
          colors: [Color(0x22FFFFFF), Color(0x08FFFFFF)],
        );
        textColor = AppColors.textSecondary;
        break;
    }

    Widget innerContent;
    if (widget.isLoading) {
      innerContent = const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryCyan),
        ),
      );
    } else {
      final children = <Widget>[];
      if (widget.icon != null) {
        children.add(Icon(widget.icon, size: 19, color: textColor));
      }
      if (widget.label != null) {
        if (children.isNotEmpty) children.add(const SizedBox(width: 8));
        children.add(
          Text(
            widget.label!,
            style: AppTypography.titleMedium.copyWith(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        );
      }
      if (widget.child != null) {
        if (children.isNotEmpty) children.add(const SizedBox(width: 8));
        children.add(widget.child!);
      }

      innerContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isEnabled ? 1.0 : 0.45,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: shadows,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: CustomPaint(
                  painter: _ButtonBorderPainter(
                    borderRadius: widget.borderRadius,
                    gradient: borderGradient,
                    strokeWidth: widget.variant == GlassButtonVariant.primary ? 1.6 : 1.1,
                  ),
                  child: Container(
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: fillColor,
                      gradient: fillGradient,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                    alignment: Alignment.center,
                    child: innerContent,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonBorderPainter extends CustomPainter {
  final double borderRadius;
  final Gradient gradient;
  final double strokeWidth;

  _ButtonBorderPainter({
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
  bool shouldRepaint(covariant _ButtonBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradient != gradient;
  }
}
