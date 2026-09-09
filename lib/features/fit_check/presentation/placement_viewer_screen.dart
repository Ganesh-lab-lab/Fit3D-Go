import 'package:flutter/material.dart';
import '../../../core/models/fit_check_record.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/room_model.dart';
import '../../../core/state/fit_engine.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_button.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/glass_sheet.dart';
import '../../../core/theme/page_transitions.dart';
import '../../wishlist/presentation/wishlist_screen.dart';
import 'widgets/fit_result_banner.dart';
import 'widgets/room_canvas_3d.dart';

class PlacementViewerScreen extends StatefulWidget {
  final RoomFitState state;

  const PlacementViewerScreen({super.key, required this.state});

  @override
  State<PlacementViewerScreen> createState() => _PlacementViewerScreenState();
}

class _PlacementViewerScreenState extends State<PlacementViewerScreen> {
  // Local placement coordinates (synced with state)
  double _posX = 0.0;
  double _posY = 0.0;
  double _rotationDeg = 0.0;
  late FitEvaluationResult _evaluation;

  @override
  void initState() {
    super.initState();
    _posX = widget.state.placementX;
    _posY = widget.state.placementY;
    _rotationDeg = widget.state.rotationDeg;
    _recalculateFit();
  }

  void _recalculateFit() {
    final room = widget.state.activeRoom;
    final product = widget.state.activeProduct;
    if (room != null && product != null) {
      _evaluation = FitEngine.evaluate(
        room: room,
        product: product,
        posX: _posX,
        posY: _posY,
        rotationDeg: _rotationDeg,
      );
    } else {
      _evaluation = const FitEvaluationResult(
        status: FitStatus.fits,
        clearanceInches: 18.0,
        description: 'Room spatial canvas ready',
      );
    }
  }

  void _updatePosition(double dx, double dy) {
    setState(() {
      _posX = (_posX + dx).clamp(-0.85, 0.85);
      _posY = (_posY + dy).clamp(-0.85, 0.85);
      _recalculateFit();
    });
    widget.state.updatePlacement(x: _posX, y: _posY);
  }

  void _updateRotation(double rot) {
    setState(() {
      _rotationDeg = rot % 360.0;
      _recalculateFit();
    });
    widget.state.updatePlacement(rotation: _rotationDeg);
  }

  void _resetPosition() {
    setState(() {
      _posX = 0.0;
      _posY = 0.0;
      _rotationDeg = 0.0;
      _recalculateFit();
    });
    widget.state.resetPlacement();
  }

  void _saveToWishlist() {
    final room = widget.state.activeRoom;
    final product = widget.state.activeProduct;
    if (room == null || product == null) return;

    final record = FitCheckRecord(
      id: 'fit_${DateTime.now().millisecondsSinceEpoch}',
      product: product,
      roomId: room.id,
      roomName: room.name,
      positionX: _posX,
      positionY: _posY,
      rotationDeg: _rotationDeg,
      fitStatus: _evaluation.status,
      clearanceInches: _evaluation.clearanceInches,
      obstructionReason: _evaluation.obstructionReason,
      timestamp: DateTime.now(),
    );

    widget.state.saveFitCheck(record);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xEE12131C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primaryCyan, width: 1.2),
        ),
        content: Row(
          children: [
            const Icon(Icons.bookmark_added_rounded, color: AppColors.primaryCyan, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved to Wishlist!',
                    style: AppTypography.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${product.title} placed in ${room.name}',
                    style: AppTypography.bodySmall.copyWith(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'View Wishlist',
          textColor: AppColors.primaryCyan,
          onPressed: () {
            Navigator.of(context).push(
              GlassPageRoute(page: WishlistScreen(state: widget.state)),
            );
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openRoomSelector() {
    showGlassBottomSheet(
      context: context,
      builder: (ctx) {
        final rooms = widget.state.rooms;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Switch Target Room', style: AppTypography.titleLarge),
              const SizedBox(height: 6),
              Text('Check fit against any of your scanned spaces', style: AppTypography.bodyMedium),
              const SizedBox(height: 16),
              ...rooms.map((r) {
                final isSelected = widget.state.activeRoom?.id == r.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    surfaceColor: isSelected ? const Color(0x3300F0FF) : AppColors.glassSurface,
                    borderColor: isSelected ? AppColors.primaryCyan : null,
                    onTap: () {
                      widget.state.setActiveRoom(r);
                      Navigator.pop(ctx);
                      setState(() {
                        _recalculateFit();
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          color: isSelected ? AppColors.primaryCyan : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.name,
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(r.dimensionsDisplay, style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: AppColors.primaryCyan, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.state.activeRoom;
    final product = widget.state.activeProduct;

    if (room == null || product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Placement Viewer')),
        body: Center(
          child: Text('No active product or room selected', style: AppTypography.bodyLarge),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. 3D Spatial Canvas (Prompt 8 requirement)
          Positioned.fill(
            child: RoomCanvas3D(
              room: room,
              product: product,
              posX: _posX,
              posY: _posY,
              rotationDeg: _rotationDeg,
              evaluation: _evaluation,
              onDragUpdate: _updatePosition,
            ),
          ),

          // 2. Top Header HUD: Back, Room Selector Pill, Wishlist shortcut
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
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),

                      // Room Switcher Pill
                      GestureDetector(
                        onTap: _openRoomSelector,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xAA141420),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0x4400F0FF)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.home_work_rounded, size: 16, color: AppColors.primaryCyan),
                              const SizedBox(width: 8),
                              Text(
                                room.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Reset Position Icon
                      IconButton(
                        tooltip: 'Reset to Center',
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0x66000000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.center_focus_strong_rounded, size: 20, color: Colors.white),
                        ),
                        onPressed: _resetPosition,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Prompt 8: Top Fit-Result Banner with 3 states & Low Confidence indicator
                  FitResultBanner(
                    evaluation: _evaluation,
                    confidence: product.confidence,
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Control Bar (Prompt 8 requirement: Move, Rotate, Reset, Wishlist)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xD90E0F17),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: Color(0x44FFFFFF), width: 1.2),
                ),
                boxShadow: [
                  BoxShadow(color: Color(0x99000000), blurRadius: 28, offset: Offset(0, -6)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Summary row
                    Row(
                      children: [
                        Text(
                          product.category.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            product.title,
                            style: AppTypography.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          product.dimensionsDisplay,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryCyan,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Rotation Control Slider & 45/90 deg snap buttons (Prompt 8 requirement)
                    Row(
                      children: [
                        const Icon(Icons.rotate_90_degrees_cw_rounded, size: 18, color: AppColors.primaryCyan),
                        const SizedBox(width: 8),
                        Text(
                          '${_rotationDeg.toInt()}°',
                          style: AppTypography.monospace.copyWith(fontSize: 13),
                        ),
                        Expanded(
                          child: Slider(
                            value: _rotationDeg,
                            min: 0.0,
                            max: 360.0,
                            onChanged: _updateRotation,
                          ),
                        ),
                        // Snap button
                        InkWell(
                          onTap: () => _updateRotation((_rotationDeg + 90.0) % 360.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0x22FFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0x33FFFFFF)),
                            ),
                            child: const Text(
                              '+90°',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryCyan,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Move Hint & "Save to Wishlist" Primary Action Button (Prompt 8 requirement)
                    Row(
                      children: [
                        // Drag move guidance
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0x1AFFFFFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x24FFFFFF)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.touch_app_rounded, size: 16, color: AppColors.textSecondary),
                              SizedBox(width: 6),
                              Text(
                                'Drag to Move',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Save to Wishlist CTA
                        Expanded(
                          child: GlassButton(
                            label: 'Save to Wishlist',
                            icon: Icons.bookmark_add_rounded,
                            variant: GlassButtonVariant.primary,
                            height: 48,
                            onPressed: _saveToWishlist,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
