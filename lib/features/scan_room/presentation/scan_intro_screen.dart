import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_button.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/page_transitions.dart';
import 'scan_ar_camera_screen.dart';

class ScanIntroScreen extends StatefulWidget {
  final RoomFitState state;

  const ScanIntroScreen({super.key, required this.state});

  @override
  State<ScanIntroScreen> createState() => _ScanIntroScreenState();
}

class _ScanIntroScreenState extends State<ScanIntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Spatial Room Scan'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                'Scan each room once —\nwe\'ll remember it',
                textAlign: TextAlign.center,
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Walk around the perimeter with your phone to build a high-precision 3D digital twin.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Animated Diagram Card
              Expanded(
                child: GlassCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(20),
                  hasTopGlow: true,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _RoomScanDiagramPainter(
                          progress: _pulseController.value,
                        ),
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Scanning Guide Points
              _buildGuidePoint(
                icon: Icons.directions_walk_rounded,
                title: 'Walk the room perimeter',
                subtitle: 'Slowly trace all 4 corners at normal walking speed',
              ),
              const SizedBox(height: 12),
              _buildGuidePoint(
                icon: Icons.meeting_room_outlined,
                title: 'Tap to tag doorways',
                subtitle: 'Mark entries and exits so products never block access',
              ),
              const SizedBox(height: 24),

              // Start Action
              GlassButton(
                label: 'Start AR Scan',
                icon: Icons.view_in_ar_rounded,
                variant: GlassButtonVariant.primary,
                height: 54,
                width: double.infinity,
                onPressed: () {
                  Navigator.of(context).push(
                    GlassPageRoute(
                      page: ScanArCameraScreen(state: widget.state),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidePoint({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0x22FFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x2BFFFFFF)),
          ),
          child: Icon(icon, color: AppColors.primaryCyan, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for walking diagram around room perimeter
class _RoomScanDiagramPainter extends CustomPainter {
  final double progress;

  _RoomScanDiagramPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final roomW = size.width * 0.72;
    final roomH = size.height * 0.65;
    final rect = Rect.fromCenter(center: center, width: roomW, height: roomH);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    // Draw floor grid lines
    final gridPaint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..strokeWidth = 1.0;

    const int cols = 5;
    const int rows = 5;
    for (int i = 1; i < cols; i++) {
      final x = rect.left + (rect.width / cols) * i;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridPaint);
    }
    for (int j = 1; j < rows; j++) {
      final y = rect.top + (rect.height / rows) * j;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
    }

    // Room wall boundaries (dashed/glowing)
    final wallPaint = Paint()
      ..color = const Color(0x4400F0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, wallPaint);

    // Doorway representation on South wall
    final doorPaint = Paint()
      ..color = AppColors.statusAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    final doorStart = Offset(rect.left + rect.width * 0.35, rect.bottom);
    final doorEnd = Offset(rect.left + rect.width * 0.65, rect.bottom);
    canvas.drawLine(doorStart, doorEnd, doorPaint);

    // Calculate walking path along perimeter
    // Perimeter length = 2 * (roomW + roomH)
    final totalPerimeter = 2 * (roomW + roomH);
    final currentDist = (progress * totalPerimeter) % totalPerimeter;

    Offset personPos;
    if (currentDist < roomW) {
      // Moving left to right along top wall
      personPos = Offset(rect.left + currentDist, rect.top);
    } else if (currentDist < roomW + roomH) {
      // Moving top to bottom along right wall
      personPos = Offset(rect.right, rect.top + (currentDist - roomW));
    } else if (currentDist < 2 * roomW + roomH) {
      // Moving right to left along bottom wall
      personPos = Offset(rect.right - (currentDist - (roomW + roomH)), rect.bottom);
    } else {
      // Moving bottom to top along left wall
      personPos = Offset(rect.left, rect.bottom - (currentDist - (2 * roomW + roomH)));
    }

    // Phone scanning radar beam from person toward room center
    final beamPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryCyan.withOpacity(0.35),
          AppColors.primaryCyan.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: personPos, radius: 80));
    canvas.drawCircle(personPos, 65, beamPaint);

    // Scanned trail arc
    final trailPaint = Paint()
      ..color = AppColors.primaryCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(personPos, 8, trailPaint);

    final personDotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(personPos, 5, personDotPaint);

    // Phone icon or indicator
    final phonePaint = Paint()
      ..color = AppColors.primaryCyan
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: personPos.translate(0, -18), width: 14, height: 22),
        const Radius.circular(3),
      ),
      phonePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoomScanDiagramPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
