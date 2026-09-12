import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/models/fit_check_record.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/models/room_model.dart';
import '../../../../core/state/fit_engine.dart';
import '../../../../core/theme/app_colors.dart';

class RoomCanvas3D extends StatelessWidget {
  final RoomModel room;
  final ProductModel product;
  final double posX; // [-0.85, 0.85]
  final double posY; // [-0.85, 0.85]
  final double rotationDeg; // [0, 360)
  final FitEvaluationResult evaluation;
  final Function(double dx, double dy) onDragUpdate;

  const RoomCanvas3D({
    super.key,
    required this.room,
    required this.product,
    required this.posX,
    required this.posY,
    required this.rotationDeg,
    required this.evaluation,
    required this.onDragUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) {
        // Convert screen drag delta into normalized room coordinate delta
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || box.size.width <= 0 || box.size.height <= 0) return;
        final size = box.size;

        // Perspective mapping scale factor
        final dxNorm = (details.delta.dx / (size.width * 0.45));
        final dyNorm = (details.delta.dy / (size.height * 0.45));

        onDragUpdate(dxNorm, dyNorm);
      },
      child: CustomPaint(
        painter: _RoomSpatialPainter(
          room: room,
          product: product,
          posX: posX,
          posY: posY,
          rotationDeg: rotationDeg,
          evaluation: evaluation,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RoomSpatialPainter extends CustomPainter {
  final RoomModel room;
  final ProductModel product;
  final double posX;
  final double posY;
  final double rotationDeg;
  final FitEvaluationResult evaluation;

  _RoomSpatialPainter({
    required this.room,
    required this.product,
    required this.posX,
    required this.posY,
    required this.rotationDeg,
    required this.evaluation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Space canvas background
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          const Color(0xFF141420),
          const Color(0xFF08080D),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final center = Offset(size.width / 2, size.height * 0.54);

    // Dynamic scale to fit room inside viewport
    final maxRoomFt = math.max(room.lengthFt, room.widthFt);
    final roomScale = (size.width * 0.68) / (maxRoomFt > 0 ? maxRoomFt : 16.0);

    final rW = room.widthFt * roomScale;
    final rL = room.lengthFt * roomScale;

    // 3D Oblique / Isometric angle (30 deg)
    const angle = 28.0 * (math.pi / 180.0);
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);

    // Floor 4 Corners (Isometric space)
    // North (Back): pN, East (Right): pE, South (Front): pS, West (Left): pW
    final pN = Offset(center.dx, center.dy - (rL + rW) * sinA * 0.5);
    final pE = Offset(center.dx + rW * cosA, center.dy + (rW - rL) * sinA * 0.5);
    final pS = Offset(center.dx, center.dy + (rL + rW) * sinA * 0.5);
    final pW = Offset(center.dx - rL * cosA, center.dy + (rL - rW) * sinA * 0.5);

    // Floor polygon
    final floorPath = Path()
      ..moveTo(pN.dx, pN.dy)
      ..lineTo(pE.dx, pE.dy)
      ..lineTo(pS.dx, pS.dy)
      ..lineTo(pW.dx, pW.dy)
      ..close();

    // Fill floor with OriginOS glass surface
    final floorFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0x1F00F0FF),
          const Color(0x0A0066FF),
        ],
      ).createShader(floorPath.getBounds());
    canvas.drawPath(floorPath, floorFill);

    // Floor Grid lines
    final gridPaint = Paint()
      ..color = const Color(0x18FFFFFF)
      ..strokeWidth = 1.0;

    final int cols = room.widthFt.round();
    for (int i = 1; i < cols; i++) {
      final t = i / cols;
      final start = Offset.lerp(pN, pE, t)!;
      final end = Offset.lerp(pW, pS, t)!;
      canvas.drawLine(start, end, gridPaint);
    }

    final int rows = room.lengthFt.round();
    for (int j = 1; j < rows; j++) {
      final t = j / rows;
      final start = Offset.lerp(pN, pW, t)!;
      final end = Offset.lerp(pE, pS, t)!;
      canvas.drawLine(start, end, gridPaint);
    }

    // 2. Extrude 3D Boundary Walls
    final wallHeight = room.ceilingHeightFt * roomScale * 0.45;
    final wallOutlinePaint = Paint()
      ..color = AppColors.primaryCyan.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Back North Wall
    final northWall = Path()
      ..moveTo(pN.dx, pN.dy)
      ..lineTo(pE.dx, pE.dy)
      ..lineTo(pE.dx, pE.dy - wallHeight)
      ..lineTo(pN.dx, pN.dy - wallHeight)
      ..close();
    canvas.drawPath(northWall, Paint()..color = const Color(0x0E00F0FF));
    canvas.drawPath(northWall, wallOutlinePaint);

    // Back West Wall
    final westWall = Path()
      ..moveTo(pN.dx, pN.dy)
      ..lineTo(pW.dx, pW.dy)
      ..lineTo(pW.dx, pW.dy - wallHeight)
      ..lineTo(pN.dx, pN.dy - wallHeight)
      ..close();
    canvas.drawPath(westWall, Paint()..color = const Color(0x1400F0FF));
    canvas.drawPath(westWall, wallOutlinePaint);

    // Floor boundary rim
    canvas.drawPath(
      floorPath,
      Paint()
        ..color = AppColors.primaryCyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    // 3. Render Doorways on walls
    for (final door in room.doorways) {
      Offset dStart;
      Offset dEnd;
      if (door.wallIndex == 0) {
        dStart = Offset.lerp(pN, pE, door.normalizedOffset - 0.08)!;
        dEnd = Offset.lerp(pN, pE, door.normalizedOffset + 0.08)!;
      } else if (door.wallIndex == 1) {
        dStart = Offset.lerp(pE, pS, door.normalizedOffset - 0.08)!;
        dEnd = Offset.lerp(pE, pS, door.normalizedOffset + 0.08)!;
      } else if (door.wallIndex == 2) {
        dStart = Offset.lerp(pS, pW, door.normalizedOffset - 0.08)!;
        dEnd = Offset.lerp(pS, pW, door.normalizedOffset + 0.08)!;
      } else {
        dStart = Offset.lerp(pW, pN, door.normalizedOffset - 0.08)!;
        dEnd = Offset.lerp(pW, pN, door.normalizedOffset + 0.08)!;
      }

      // Doorway portal arch
      final doorPaint = Paint()
        ..color = AppColors.statusAmber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawLine(dStart, dEnd, doorPaint);
      canvas.drawLine(dStart, dStart.translate(0, -wallHeight * 0.75), doorPaint);
      canvas.drawLine(dEnd, dEnd.translate(0, -wallHeight * 0.75), doorPaint);
      canvas.drawLine(
        dStart.translate(0, -wallHeight * 0.75),
        dEnd.translate(0, -wallHeight * 0.75),
        doorPaint,
      );
    }

    // 4. Product 3D Placement & Real-time Collision Rendering (Prompt 8 requirement)
    // Map normalized posX, posY onto floor plane
    // posX along East/West axis, posY along North/South axis
    final floorCenter = center;
    final prodFloorX = floorCenter.dx + (posX * rW * 0.45 * cosA) - (posY * rL * 0.45 * cosA);
    final prodFloorY = floorCenter.dy + (posX * rW * 0.45 * sinA * 0.5) + (posY * rL * 0.45 * sinA * 0.5);
    final productCenter = Offset(prodFloorX, prodFloorY);

    // Product dimension in canvas scale
    final prodL = (product.lengthIn / 12.0) * roomScale;
    final prodW = (product.widthIn / 12.0) * roomScale;
    final prodH = (product.heightIn / 12.0) * roomScale * 0.5;

    // Is there collision? Prompt 8: "semi-transparent when overlapping something"
    final bool isColliding = evaluation.status == FitStatus.wontFit;
    final bool isTight = evaluation.status == FitStatus.tight;

    // Shading colors based on collision status
    Color itemColor;
    double itemOpacity;
    if (isColliding) {
      itemColor = AppColors.statusRed;
      itemOpacity = 0.35; // Semi-transparent when overlapping something!
    } else if (isTight) {
      itemColor = AppColors.statusAmber;
      itemOpacity = 0.75;
    } else {
      itemColor = AppColors.primaryCyan;
      itemOpacity = 0.90;
    }

    // Draw Floor Drop-Shadow under product
    final shadowPaint = Paint()
      ..color = isColliding ? const Color(0x66FF3B30) : const Color(0x55000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(center: productCenter, width: math.max(prodL, prodW) * 1.3, height: math.min(prodL, prodW) * 0.8),
      shadowPaint,
    );

    // 3D Product Box Model
    _draw3DProductModel(
      canvas: canvas,
      center: productCenter,
      length: prodL,
      width: prodW,
      height: prodH,
      rotationDeg: rotationDeg,
      color: itemColor,
      opacity: itemOpacity,
      isColliding: isColliding,
    );

    // Collision warning beacon if overlapping
    if (isColliding) {
      final warningPaint = Paint()
        ..color = AppColors.statusRed
        ..style = PaintingStyle.fill;
      canvas.drawCircle(productCenter.translate(0, -prodH - 16), 14, warningPaint);
      final whiteIcon = Paint()..color = Colors.white..strokeWidth = 2.5;
      final cP = productCenter.translate(0, -prodH - 16);
      canvas.drawLine(cP.translate(0, -6), cP.translate(0, 2), whiteIcon);
      canvas.drawCircle(cP.translate(0, 6), 1.5, Paint()..color = Colors.white);
    }
  }

  void _draw3DProductModel({
    required Canvas canvas,
    required Offset center,
    required double length,
    required double width,
    required double height,
    required double rotationDeg,
    required Color color,
    required double opacity,
    required bool isColliding,
  }) {
    final rad = rotationDeg * (math.pi / 180.0);
    final cosR = math.cos(rad);
    final sinR = math.sin(rad);

    // Isometric projection angles
    const angle = 28.0 * (math.pi / 180.0);
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);

    final halfL = length / 2;
    final halfW = width / 2;

    // 4 Rotated floor corners in local space
    final List<math.Point<double>> corners = [
      math.Point(-halfW, -halfL),
      math.Point(halfW, -halfL),
      math.Point(halfW, halfL),
      math.Point(-halfW, halfL),
    ];

    // Project onto isometric canvas
    final List<Offset> bCorners = corners.map((pt) {
      final rx = pt.x * cosR - pt.y * sinR;
      final ry = pt.x * sinR + pt.y * cosR;
      final isoX = center.dx + (rx * cosA - ry * cosA);
      final isoY = center.dy + (rx + ry) * sinA * 0.5;
      return Offset(isoX, isoY);
    }).toList();

    // Top corners (extruded upwards by height)
    final List<Offset> tCorners = bCorners.map((b) => b.translate(0, -height)).toList();

    // 1. Top Face
    final topPath = Path()
      ..moveTo(tCorners[0].dx, tCorners[0].dy)
      ..lineTo(tCorners[1].dx, tCorners[1].dy)
      ..lineTo(tCorners[2].dx, tCorners[2].dy)
      ..lineTo(tCorners[3].dx, tCorners[3].dy)
      ..close();

    final topPaint = Paint()..color = color.withOpacity(opacity * 0.4);
    canvas.drawPath(topPath, topPaint);

    // 2. Side Facets
    final strokePaint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isColliding ? 2.6 : 1.8;

    for (int i = 0; i < 4; i++) {
      final next = (i + 1) % 4;
      final sidePath = Path()
        ..moveTo(bCorners[i].dx, bCorners[i].dy)
        ..lineTo(bCorners[next].dx, bCorners[next].dy)
        ..lineTo(tCorners[next].dx, tCorners[next].dy)
        ..lineTo(tCorners[i].dx, tCorners[i].dy)
        ..close();

      final sideShade = Paint()..color = color.withOpacity(opacity * 0.25);
      canvas.drawPath(sidePath, sideShade);
      canvas.drawPath(sidePath, strokePaint);
    }

    // Top edge wireframe
    canvas.drawPath(topPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _RoomSpatialPainter oldDelegate) {
    return oldDelegate.posX != posX ||
        oldDelegate.posY != posY ||
        oldDelegate.rotationDeg != rotationDeg ||
        oldDelegate.evaluation.status != evaluation.status ||
        oldDelegate.room.id != room.id ||
        oldDelegate.product.id != product.id;
  }
}
