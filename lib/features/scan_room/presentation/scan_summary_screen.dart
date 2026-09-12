import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/room_model.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_button.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/page_transitions.dart';
import '../../rooms/presentation/my_home_screen.dart';
import 'scan_ar_camera_screen.dart';

class ScanSummaryScreen extends StatefulWidget {
  final RoomFitState state;
  final RoomModel scannedRoom;

  const ScanSummaryScreen({
    super.key,
    required this.state,
    required this.scannedRoom,
  });

  @override
  State<ScanSummaryScreen> createState() => _ScanSummaryScreenState();
}

class _ScanSummaryScreenState extends State<ScanSummaryScreen> {
  late TextEditingController _nameController;
  late double _lengthFt;
  late double _widthFt;
  late double _ceilingHeightFt;

  final List<String> _nameSuggestions = [
    'Living Room',
    'Primary Bedroom',
    'Dining Room',
    'Guest Room',
    'Home Office',
    'Kitchen',
  ];

  @override
  void initState() {
    super.initState();
    _lengthFt = widget.scannedRoom.lengthFt;
    _widthFt = widget.scannedRoom.widthFt;
    _ceilingHeightFt = widget.scannedRoom.ceilingHeightFt;

    final existingCount = widget.state.rooms.length;
    _nameController = TextEditingController(
      text: existingCount < _nameSuggestions.length
          ? _nameSuggestions[existingCount]
          : 'Room ${existingCount + 1}',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveAndProceed({bool addAnother = false}) {
    final finalRoom = widget.scannedRoom.copyWith(
      name: _nameController.text.trim().isEmpty
          ? 'Scanned Room'
          : _nameController.text.trim(),
      lengthFt: _lengthFt,
      widthFt: _widthFt,
      ceilingHeightFt: _ceilingHeightFt,
    );

    widget.state.addRoom(finalRoom);

    if (addAnother) {
      Navigator.of(context).pushReplacement(
        GlassPageRoute(page: ScanArCameraScreen(state: widget.state)),
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        GlassPageRoute(page: MyHomeScreen(state: widget.state)),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Room Scan Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          physics: const BouncingScrollPhysics(),
          children: [
            // Success Header Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x2E00E676),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x6600E676)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.statusGreen, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '3D Room Mesh Generated',
                      style: AppTypography.badge.copyWith(
                        color: AppColors.statusGreen,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 1. Editable Room Name
            Text('Room Name', style: AppTypography.label),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: AppTypography.titleMedium.copyWith(fontSize: 18),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded, color: AppColors.primaryCyan),
                hintText: 'e.g. Living Room, Bedroom',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppColors.textTertiary),
                  onPressed: () => _nameController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Quick suggestion chips
            Wrap(
              spacing: 8,
              children: _nameSuggestions.take(4).map((name) {
                return ActionChip(
                  label: Text(name),
                  backgroundColor: const Color(0x1AFFFFFF),
                  side: const BorderSide(color: Color(0x22FFFFFF)),
                  labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  onPressed: () {
                    setState(() => _nameController.text = name);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            // 2. Detected Dimensions Display Card (Prompt 2 requirement)
            Text('Detected Dimensions', style: AppTypography.label),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              hasTopGlow: true,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDimensionStat(
                        label: 'Floor Plan',
                        value: '${_lengthFt.toStringAsFixed(1)}ft x ${_widthFt.toStringAsFixed(1)}ft',
                        subtext: 'L x W boundary',
                      ),
                      Container(width: 1, height: 48, color: const Color(0x22FFFFFF)),
                      _buildDimensionStat(
                        label: 'Ceiling Height',
                        value: '${_ceilingHeightFt.toStringAsFixed(0)}ft',
                        subtext: 'Vertical clearance',
                      ),
                      Container(width: 1, height: 48, color: const Color(0x22FFFFFF)),
                      _buildDimensionStat(
                        label: 'Total Area',
                        value: '${(_lengthFt * _widthFt).toStringAsFixed(0)} sq ft',
                        subtext: 'Floor footprint',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.meeting_room_outlined, size: 18, color: AppColors.statusAmber),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.scannedRoom.doorways.length} Doorway(s) tagged for collision checking',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 3. 2D/3D Scanned Wireframe Floor Plan Preview
            Text('Spatial Mesh Preview', style: AppTypography.label),
            const SizedBox(height: 8),
            GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              height: 180,
              child: CustomPaint(
                painter: _SummaryMeshPreviewPainter(
                  lengthFt: _lengthFt,
                  widthFt: _widthFt,
                  doorways: widget.scannedRoom.doorways,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 28),

            // Action: Save Button (Primary)
            GlassButton(
              label: 'Save Room',
              icon: Icons.bookmark_added_rounded,
              variant: GlassButtonVariant.primary,
              height: 52,
              onPressed: () => _saveAndProceed(addAnother: false),
            ),
            const SizedBox(height: 12),

            // Action: Add Another Room (Secondary)
            GlassButton(
              label: 'Add Another Room',
              icon: Icons.add_rounded,
              variant: GlassButtonVariant.secondary,
              height: 52,
              onPressed: () => _saveAndProceed(addAnother: true),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionStat({
    required String label,
    required String value,
    required String subtext,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primaryCyan,
            fontSize: 16,
          ),
        ),
        Text(subtext, style: AppTypography.bodySmall.copyWith(fontSize: 9)),
      ],
    );
  }
}

class _SummaryMeshPreviewPainter extends CustomPainter {
  final double lengthFt;
  final double widthFt;
  final List<DoorwayMarker> doorways;

  _SummaryMeshPreviewPainter({
    required this.lengthFt,
    required this.widthFt,
    required this.doorways,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxDim = math.max(lengthFt, widthFt);
    final scale = (size.height * 0.7) / (maxDim > 0 ? maxDim : 15.0);

    final w = widthFt * scale;
    final l = lengthFt * scale;

    final rect = Rect.fromCenter(center: center, width: w, height: l);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    // Floor fill
    canvas.drawRRect(
      rrect,
      Paint()..color = const Color(0x1400F0FF),
    );

    // Floor grid
    final gridPaint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..strokeWidth = 1.0;
    for (double x = rect.left + 20; x < rect.right; x += 20) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridPaint);
    }
    for (double y = rect.top + 20; y < rect.bottom; y += 20) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
    }

    // Room Walls
    final wallPaint = Paint()
      ..color = AppColors.primaryCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawRRect(rrect, wallPaint);

    // Doorways
    final doorPaint = Paint()
      ..color = AppColors.statusAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (final door in doorways) {
      if (door.wallIndex == 0) {
        // North wall
        final dx = rect.left + (rect.width * door.normalizedOffset);
        canvas.drawLine(Offset(dx - 12, rect.top), Offset(dx + 12, rect.top), doorPaint);
      } else if (door.wallIndex == 1) {
        // East wall
        final dy = rect.top + (rect.height * door.normalizedOffset);
        canvas.drawLine(Offset(rect.right, dy - 12), Offset(rect.right, dy + 12), doorPaint);
      } else if (door.wallIndex == 2) {
        // South wall
        final dx = rect.left + (rect.width * door.normalizedOffset);
        canvas.drawLine(Offset(dx - 12, rect.bottom), Offset(dx + 12, rect.bottom), doorPaint);
      } else {
        // West wall
        final dy = rect.top + (rect.height * door.normalizedOffset);
        canvas.drawLine(Offset(rect.left, dy - 12), Offset(rect.left, dy + 12), doorPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SummaryMeshPreviewPainter oldDelegate) {
    return oldDelegate.lengthFt != lengthFt ||
        oldDelegate.widthFt != widthFt ||
        oldDelegate.doorways.length != doorways.length;
  }
}
