import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../theme/app_colors.dart';

class ProxyShape3DPreview extends StatelessWidget {
  final ProductCategory category;
  final double lengthIn;
  final double widthIn;
  final double heightIn;
  final Color accentColor;
  final double size;

  const ProxyShape3DPreview({
    super.key,
    required this.category,
    required this.lengthIn,
    required this.widthIn,
    required this.heightIn,
    this.accentColor = AppColors.primaryCyan,
    this.size = 140.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IsometricProxyPainter(
          category: category,
          lengthIn: lengthIn,
          widthIn: widthIn,
          heightIn: heightIn,
          accentColor: accentColor,
        ),
      ),
    );
  }
}

class _IsometricProxyPainter extends CustomPainter {
  final ProductCategory category;
  final double lengthIn;
  final double widthIn;
  final double heightIn;
  final Color accentColor;

  _IsometricProxyPainter({
    required this.category,
    required this.lengthIn,
    required this.widthIn,
    required this.heightIn,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.56);

    // Normalize scale
    final maxDim = math.max(lengthIn, math.max(widthIn, heightIn));
    final scale = (size.width * 0.42) / (maxDim > 0 ? maxDim : 60.0);

    final l = (lengthIn * scale).clamp(24.0, size.width * 0.46);
    final w = (widthIn * scale).clamp(20.0, size.width * 0.42);
    final h = (heightIn * scale).clamp(18.0, size.height * 0.38);

    // Isometric projection basis vectors (30 degrees)
    const angle = 30.0 * (math.pi / 180.0);
    final cos30 = math.cos(angle);
    final sin30 = math.sin(angle);

    // Floor shadow
    final shadowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + l * cos30, center.dy - l * sin30 * 0.5)
      ..lineTo(center.dx + (l - w) * cos30, center.dy + (l + w) * sin30 * 0.5)
      ..lineTo(center.dx - w * cos30, center.dy - w * sin30 * 0.5)
      ..close();

    final shadowPaint = Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(shadowPath, shadowPaint);

    switch (category) {
      case ProductCategory.sofa:
        _drawSofa(canvas, center, l, w, h, cos30, sin30);
        break;
      case ProductCategory.table:
        _drawTable(canvas, center, l, w, h, cos30, sin30);
        break;
      case ProductCategory.shelf:
        _drawShelf(canvas, center, l, w, h, cos30, sin30);
        break;
      case ProductCategory.lamp:
        _drawLamp(canvas, center, l, w, h, cos30, sin30);
        break;
      case ProductCategory.other:
        _drawBox(canvas, center, l, w, h, cos30, sin30);
        break;
    }
  }

  void _drawBox(Canvas canvas, Offset c, double l, double w, double h, double cos30, double sin30) {
    // 8 Isometric Vertices
    // Bottom: B0(front), B1(right), B2(back), B3(left)
    final b0 = Offset(c.dx + (l - w) * cos30 * 0.5, c.dy + (l + w) * sin30 * 0.5);
    final b1 = Offset(c.dx + l * cos30, c.dy);
    final b2 = Offset(c.dx - (l - w) * cos30 * 0.5, c.dy - (l + w) * sin30 * 0.5);
    final b3 = Offset(c.dx - w * cos30, c.dy);

    // Top:
    final t0 = b0.translate(0, -h);
    final t1 = b1.translate(0, -h);
    final t2 = b2.translate(0, -h);
    final t3 = b3.translate(0, -h);

    final strokePaint = Paint()
      ..color = accentColor.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final topPaint = Paint()..color = accentColor.withOpacity(0.24);
    final leftPaint = Paint()..color = accentColor.withOpacity(0.12);
    final rightPaint = Paint()..color = accentColor.withOpacity(0.18);

    // Top face
    final topPath = Path()..moveTo(t0.dx, t0.dy)..lineTo(t1.dx, t1.dy)..lineTo(t2.dx, t2.dy)..lineTo(t3.dx, t3.dy)..close();
    canvas.drawPath(topPath, topPaint);
    canvas.drawPath(topPath, strokePaint);

    // Left face
    final leftPath = Path()..moveTo(t3.dx, t3.dy)..lineTo(t0.dx, t0.dy)..lineTo(b0.dx, b0.dy)..lineTo(b3.dx, b3.dy)..close();
    canvas.drawPath(leftPath, leftPaint);
    canvas.drawPath(leftPath, strokePaint);

    // Right face
    final rightPath = Path()..moveTo(t0.dx, t0.dy)..lineTo(t1.dx, t1.dy)..lineTo(b1.dx, b1.dy)..lineTo(b0.dx, b0.dy)..close();
    canvas.drawPath(rightPath, rightPaint);
    canvas.drawPath(rightPath, strokePaint);
  }

  void _drawSofa(Canvas canvas, Offset c, double l, double w, double h, double cos30, double sin30) {
    // Base seat cushion
    _drawBox(canvas, c, l, w, h * 0.45, cos30, sin30);
    // Backrest (taller on the back edge)
    final backOffset = Offset(c.dx - w * cos30 * 0.35, c.dy - w * sin30 * 0.35);
    _drawBox(canvas, backOffset.translate(0, -h * 0.3), l, w * 0.35, h * 0.7, cos30, sin30);
  }

  void _drawTable(Canvas canvas, Offset c, double l, double w, double h, double cos30, double sin30) {
    // Tabletop
    final topOffset = c.translate(0, -h * 0.85);
    _drawBox(canvas, topOffset, l, w, h * 0.15, cos30, sin30);

    // 4 Table legs
    final legPaint = Paint()
      ..color = accentColor.withOpacity(0.7)
      ..strokeWidth = 2.0;

    final b0 = Offset(c.dx + (l - w) * cos30 * 0.45, c.dy + (l + w) * sin30 * 0.45);
    final b1 = Offset(c.dx + l * cos30 * 0.85, c.dy);
    final b2 = Offset(c.dx - (l - w) * cos30 * 0.45, c.dy - (l + w) * sin30 * 0.45);
    final b3 = Offset(c.dx - w * cos30 * 0.85, c.dy);

    canvas.drawLine(b0, b0.translate(0, -h * 0.8), legPaint);
    canvas.drawLine(b1, b1.translate(0, -h * 0.8), legPaint);
    canvas.drawLine(b2, b2.translate(0, -h * 0.8), legPaint);
    canvas.drawLine(b3, b3.translate(0, -h * 0.8), legPaint);
  }

  void _drawShelf(Canvas canvas, Offset c, double l, double w, double h, double cos30, double sin30) {
    // Outer tall frame
    _drawBox(canvas, c, l, w, h, cos30, sin30);
    // 2 Interior shelf dividers
    final s1 = c.translate(0, -h * 0.33);
    final s2 = c.translate(0, -h * 0.66);
    final divPaint = Paint()..color = accentColor.withOpacity(0.6)..strokeWidth = 1.4;
    canvas.drawLine(s1.translate(-w * cos30 * 0.5, 0), s1.translate(l * cos30 * 0.5, 0), divPaint);
    canvas.drawLine(s2.translate(-w * cos30 * 0.5, 0), s2.translate(l * cos30 * 0.5, 0), divPaint);
  }

  void _drawLamp(Canvas canvas, Offset c, double l, double w, double h, double cos30, double sin30) {
    // Round circular base
    final basePaint = Paint()..color = accentColor.withOpacity(0.35);
    canvas.drawOval(Rect.fromCenter(center: c, width: w * 0.8, height: w * 0.4), basePaint);

    // Stem pole
    final stemPaint = Paint()..color = accentColor.withOpacity(0.85)..strokeWidth = 2.4;
    final topCenter = c.translate(0, -h);
    canvas.drawLine(c, topCenter, stemPaint);

    // Lampshade cone / cylinder
    final shadePaint = Paint()..color = accentColor.withOpacity(0.3);
    final shadeBorder = Paint()..color = accentColor..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final shadePath = Path()
      ..moveTo(topCenter.dx - w * 0.4, topCenter.dy + h * 0.25)
      ..lineTo(topCenter.dx + w * 0.4, topCenter.dy + h * 0.25)
      ..lineTo(topCenter.dx + w * 0.25, topCenter.dy)
      ..lineTo(topCenter.dx - w * 0.25, topCenter.dy)
      ..close();
    canvas.drawPath(shadePath, shadePaint);
    canvas.drawPath(shadePath, shadeBorder);
  }

  @override
  bool shouldRepaint(covariant _IsometricProxyPainter oldDelegate) {
    return oldDelegate.category != category ||
        oldDelegate.lengthIn != lengthIn ||
        oldDelegate.widthIn != widthIn ||
        oldDelegate.heightIn != heightIn ||
        oldDelegate.accentColor != accentColor;
  }
}
