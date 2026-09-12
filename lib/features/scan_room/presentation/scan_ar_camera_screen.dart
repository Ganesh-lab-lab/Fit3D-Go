import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/room_model.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_button.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/page_transitions.dart';
import '../../../core/utils/uuid_util.dart';
import 'scan_summary_screen.dart';

class ScanArCameraScreen extends StatefulWidget {
  final RoomFitState state;

  const ScanArCameraScreen({super.key, required this.state});

  @override
  State<ScanArCameraScreen> createState() => _ScanArCameraScreenState();
}

class _ScanArCameraScreenState extends State<ScanArCameraScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _meshAnimController;
  Timer? _coverageTimer;
  double _coveragePercent = 15.0; // 0 to 100%
  final List<DoorwayMarker> _taggedDoorways = [];

  // Estimated dimensions during scan
  double _estLength = 12.0;
  double _estWidth = 10.0;
  double _estCeiling = 8.5;

  @override
  void initState() {
    super.initState();
    _meshAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Simulate real-time AR point cloud and mesh accumulation
    _coverageTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (!mounted) return;
      setState(() {
        if (_coveragePercent < 94.0) {
          _coveragePercent += 1.8;
          _estLength = 12.0 + (_coveragePercent / 94.0) * 3.2;
          _estWidth = 10.0 + (_coveragePercent / 94.0) * 2.4;
          _estCeiling = 9.0;
        }
      });
    });
  }

  @override
  void dispose() {
    _coverageTimer?.cancel();
    _meshAnimController.dispose();
    super.dispose();
  }

  void _onTapViewport(TapUpDetails details, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    // Determine closest wall based on tap position
    final relX = details.localPosition.dx / size.width;
    final relY = details.localPosition.dy / size.height;

    // Pick wall index: 0=North, 1=East, 2=South, 3=West
    int wallIdx;
    double offset;

    if (relY < 0.35) {
      wallIdx = 0; // North
      offset = relX;
    } else if (relX > 0.7) {
      wallIdx = 1; // East
      offset = relY;
    } else if (relY > 0.65) {
      wallIdx = 2; // South
      offset = relX;
    } else {
      wallIdx = 3; // West
      offset = relY;
    }

    final newDoor = DoorwayMarker(
      id: 'door_${DateTime.now().millisecondsSinceEpoch}',
      wallIndex: wallIdx,
      normalizedOffset: offset.clamp(0.15, 0.85),
      widthFt: 3.0,
    );

    setState(() {
      _taggedDoorways.add(newDoor);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xEE14141E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.primaryCyan, width: 1),
        ),
        content: Row(
          children: [
            const Icon(Icons.meeting_room_rounded, color: AppColors.primaryCyan, size: 20),
            const SizedBox(width: 10),
            Text(
              'Doorway ${_taggedDoorways.length} tagged on ${_getWallName(wallIdx)} wall',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getWallName(int idx) {
    switch (idx) {
      case 0:
        return 'North';
      case 1:
        return 'East';
      case 2:
        return 'South';
      case 3:
      default:
        return 'West';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return Stack(
            children: [
              // 1. Simulated Camera Viewport & AR 3D Floor Mesh
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => _onTapViewport(details, size),
                child: SizedBox.expand(
                  child: AnimatedBuilder(
                    animation: _meshAnimController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _ArCameraMeshPainter(
                          pulseValue: _meshAnimController.value,
                          coveragePercent: _coveragePercent,
                          taggedDoors: _taggedDoorways,
                        ),
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
                ),
              ),

              // 2. Top Header HUD: Back button, AR Indicator, Coverage Bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0x66000000),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          // AR Session Status Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0x99000000),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0x3300F0FF)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.statusGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'ARKit / ARCore Live',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Coverage Indicator Card
                      GlassCard(
                        borderRadius: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        surfaceColor: const Color(0x33101018),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: _coveragePercent / 100.0,
                                    strokeWidth: 4,
                                    backgroundColor: const Color(0x22FFFFFF),
                                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryCyan),
                                  ),
                                  Text(
                                    '${_coveragePercent.toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mesh Coverage: ${_coveragePercent.toInt()}%',
                                    style: AppTypography.titleMedium.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Est: ${_estLength.toStringAsFixed(1)}ft x ${_estWidth.toStringAsFixed(1)}ft, ${_estCeiling.toStringAsFixed(0)}ft ceil',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primaryCyan,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Center Floating Prompt: Tap to Tag Doorway
              Positioned(
                bottom: 120,
                left: 20,
                right: 20,
                child: Center(
                  child: GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    surfaceColor: const Color(0x4D000000),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          color: AppColors.statusAmber,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tap screen perimeter to mark doorway location',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Bottom Controls: Finish Scan Button
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: GlassButton(
                  label: _coveragePercent >= 50
                      ? 'Finish & Review Room'
                      : 'Scanning... (${_coveragePercent.toInt()}%)',
                  icon: Icons.check_circle_outline_rounded,
                  variant: GlassButtonVariant.primary,
                  height: 54,
                  onPressed: () {
                    // Navigate to Screen 3: Room Summary
                    final detectedRoom = RoomModel(
                      id: UuidUtil.generate(),
                      name: 'Scanned Room',
                      lengthFt: double.parse(_estLength.toStringAsFixed(1)),
                      widthFt: double.parse(_estWidth.toStringAsFixed(1)),
                      ceilingHeightFt: 9.0,
                      scannedDate: DateTime.now(),
                      doorways: List.from(_taggedDoorways),
                    );

                    Navigator.of(context).push(
                      GlassPageRoute(
                        page: ScanSummaryScreen(
                          state: widget.state,
                          scannedRoom: detectedRoom,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Simulated AR camera background with wireframe floor plan and mesh triangles
class _ArCameraMeshPainter extends CustomPainter {
  final double pulseValue;
  final double coveragePercent;
  final List<DoorwayMarker> taggedDoors;

  _ArCameraMeshPainter({
    required this.pulseValue,
    required this.coveragePercent,
    required this.taggedDoors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dark atmospheric camera backdrop with vignette
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          const Color(0xFF161922),
          const Color(0xFF07080B),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Spatial 3D Perspective Plane for Room Floor
    final horizonY = size.height * 0.42;
    final center = Offset(size.width / 2, horizonY + (size.height - horizonY) * 0.55);

    final fWidth = size.width * 0.82;
    final fHeight = (size.height - horizonY) * 0.68;

    // 4 Corner Vertices of perspective floor
    final pTopLeft = Offset(center.dx - fWidth * 0.38, horizonY + fHeight * 0.1);
    final pTopRight = Offset(center.dx + fWidth * 0.38, horizonY + fHeight * 0.1);
    final pBottomRight = Offset(center.dx + fWidth * 0.52, horizonY + fHeight * 0.95);
    final pBottomLeft = Offset(center.dx - fWidth * 0.52, horizonY + fHeight * 0.95);

    // 3. Translucent Floor Mesh Poly
    final floorPath = Path()
      ..moveTo(pTopLeft.dx, pTopLeft.dy)
      ..lineTo(pTopRight.dx, pTopRight.dy)
      ..lineTo(pBottomRight.dx, pBottomRight.dy)
      ..lineTo(pBottomLeft.dx, pBottomLeft.dy)
      ..close();

    final floorFill = Paint()
      ..color = AppColors.primaryCyan.withOpacity(0.08 * (coveragePercent / 100.0));
    canvas.drawPath(floorPath, floorFill);

    // 4. Perspective Grid & Triangulated Mesh Lines
    final linePaint = Paint()
      ..color = AppColors.primaryCyan.withOpacity(0.28)
      ..strokeWidth = 1.0;

    const int divisions = 6;
    for (int i = 0; i <= divisions; i++) {
      final t = i / divisions;
      // Longitudinal perspective lines
      final start = Offset.lerp(pTopLeft, pTopRight, t)!;
      final end = Offset.lerp(pBottomLeft, pBottomRight, t)!;
      canvas.drawLine(start, end, linePaint);

      // Latitudinal lines
      final lStart = Offset.lerp(pTopLeft, pBottomLeft, t)!;
      final lEnd = Offset.lerp(pTopRight, pBottomRight, t)!;
      canvas.drawLine(lStart, lEnd, linePaint);
    }

    // 5. Triangular Mesh Wireframe Overlay (AR spatial reconstruction effect)
    final trianglePaint = Paint()
      ..color = AppColors.primaryCyan.withOpacity(0.18 + (pulseValue * 0.15))
      ..strokeWidth = 0.8;

    for (int i = 0; i < divisions; i++) {
      final t1 = i / divisions;
      final t2 = (i + 1) / divisions;
      final p1 = Offset.lerp(pTopLeft, pBottomLeft, t1)!;
      final p2 = Offset.lerp(pTopRight, pBottomRight, t2)!;
      canvas.drawLine(p1, p2, trianglePaint);
    }

    // 6. Glowing Boundary Walls (Extruded upwards)
    final wallHeight = (size.height - horizonY) * 0.38;
    final wallStroke = Paint()
      ..color = AppColors.primaryCyan
      ..strokeWidth = 2.4;

    // Draw vertical corner pillars
    canvas.drawLine(pTopLeft, pTopLeft.translate(0, -wallHeight * 0.7), wallStroke);
    canvas.drawLine(pTopRight, pTopRight.translate(0, -wallHeight * 0.7), wallStroke);
    canvas.drawLine(pBottomLeft, pBottomLeft.translate(0, -wallHeight), wallStroke);
    canvas.drawLine(pBottomRight, pBottomRight.translate(0, -wallHeight), wallStroke);

    // Perimeter bottom line
    canvas.drawPath(
      floorPath,
      Paint()
        ..color = AppColors.primaryCyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 7. Render Tagged Doorway Markers
    for (final door in taggedDoors) {
      Offset dPos;
      if (door.wallIndex == 0) {
        dPos = Offset.lerp(pTopLeft, pTopRight, door.normalizedOffset)!;
      } else if (door.wallIndex == 1) {
        dPos = Offset.lerp(pTopRight, pBottomRight, door.normalizedOffset)!;
      } else if (door.wallIndex == 2) {
        dPos = Offset.lerp(pBottomRight, pBottomLeft, door.normalizedOffset)!;
      } else {
        dPos = Offset.lerp(pBottomLeft, pTopLeft, door.normalizedOffset)!;
      }

      // Amber Doorway marker pin
      final doorPaint = Paint()..color = AppColors.statusAmber;
      canvas.drawCircle(dPos, 9, doorPaint);
      canvas.drawCircle(
        dPos,
        15 + (pulseValue * 6),
        Paint()
          ..color = AppColors.statusAmber.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Vertical door outline
      canvas.drawLine(
        dPos,
        dPos.translate(0, -42),
        Paint()
          ..color = AppColors.statusAmber
          ..strokeWidth = 3,
      );
    }

    // 8. Scanning Radar sweep line
    final scanY = horizonY + (size.height - horizonY) * pulseValue;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primaryCyan.withOpacity(0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, scanY, size.width, 3));
    canvas.drawRect(Rect.fromLTWH(0, scanY, size.width, 3), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _ArCameraMeshPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.coveragePercent != coveragePercent ||
        oldDelegate.taggedDoors.length != taggedDoors.length;
  }
}
