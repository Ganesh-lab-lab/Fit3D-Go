import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/room_model.dart';
import '../../../core/theme/app_colors.dart';

class RoomThumbnailPainter extends CustomPainter {
  final double lengthFt;
  final double widthFt;
  final List<DoorwayMarker> doorways;

  RoomThumbnailPainter({
    required this.lengthFt,
    required this.widthFt,
    required this.doorways,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxDim = math.max(lengthFt, widthFt);
    final scale = (size.width * 0.72) / (maxDim > 0 ? maxDim : 14.0);

    final w = widthFt * scale;
    final l = lengthFt * scale;

    final rect = Rect.fromCenter(center: center, width: w, height: l);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    // Floor fill gradient
    final floorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x2E00F0FF), Color(0x0F0066FF)],
      ).createShader(rect);
    canvas.drawRRect(rrect, floorPaint);

    // Wall stroke
    final wallPaint = Paint()
      ..color = AppColors.primaryCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(rrect, wallPaint);

    // Doorway markers
    final doorPaint = Paint()
      ..color = AppColors.statusAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (final door in doorways) {
      if (door.wallIndex == 0) {
        final dx = rect.left + (rect.width * door.normalizedOffset);
        canvas.drawLine(Offset(dx - 5, rect.top), Offset(dx + 5, rect.top), doorPaint);
      } else if (door.wallIndex == 1) {
        final dy = rect.top + (rect.height * door.normalizedOffset);
        canvas.drawLine(Offset(rect.right, dy - 5), Offset(rect.right, dy + 5), doorPaint);
      } else if (door.wallIndex == 2) {
        final dx = rect.left + (rect.width * door.normalizedOffset);
        canvas.drawLine(Offset(dx - 5, rect.bottom), Offset(dx + 5, rect.bottom), doorPaint);
      } else {
        final dy = rect.top + (rect.height * door.normalizedOffset);
        canvas.drawLine(Offset(rect.left, dy - 5), Offset(rect.left, dy + 5), doorPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoomThumbnailPainter oldDelegate) {
    return oldDelegate.lengthFt != lengthFt ||
        oldDelegate.widthFt != widthFt ||
        oldDelegate.doorways.length != doorways.length;
  }
}
