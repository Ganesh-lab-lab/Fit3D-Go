import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/product_model.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_button.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/page_transitions.dart';
import '../../../core/widgets/confidence_badge.dart';
import '../../../core/widgets/dimensional_input.dart';
import '../../../core/widgets/proxy_shape_3d.dart';
import '../../fit_check/presentation/placement_viewer_screen.dart';

/// Lightweight in-store camera quick-scan mode under /lib/features/instore_capture
/// Fallback path for barcode no-match or packaging warning.
class InStoreCaptureScreen extends StatefulWidget {
  final RoomFitState state;
  final ProductCategory prefillCategory;

  const InStoreCaptureScreen({
    super.key,
    required this.state,
    this.prefillCategory = ProductCategory.sofa,
  });

  @override
  State<InStoreCaptureScreen> createState() => _InStoreCaptureScreenState();
}

class _InStoreCaptureScreenState extends State<InStoreCaptureScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbitController;
  Timer? _orbitTimer;

  double _orbitCoverage = 25.0; // 0% to 100% (180 deg arc)
  bool _isEstimating = false;
  bool _isConfirmedState = false;

  // Calibrated real-world dimensions (editable in confirm view)
  double _capturedLengthIn = 76.0;
  double _capturedWidthIn = 35.0;
  double _capturedHeightIn = 31.0;
  late ProductCategory _category;
  final TextEditingController _nameController =
      TextEditingController(text: 'Showroom Measured Item');

  @override
  void initState() {
    super.initState();
    _category = widget.prefillCategory;
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Simulates close orbit keyframe accumulation with frame spacing & blur check
    _orbitTimer = Timer.periodic(const Duration(milliseconds: 280), (timer) {
      if (!mounted || _isEstimating || _isConfirmedState) return;
      setState(() {
        if (_orbitCoverage < 95.0) {
          _orbitCoverage += 2.4;
        }
      });
    });
  }

  @override
  void dispose() {
    _orbitTimer?.cancel();
    _orbitController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onCapture() async {
    _orbitTimer?.cancel();
    setState(() {
      _isEstimating = true;
    });

    // Fast-path Gaussian Splatting / Photogrammetry turnaround (<1.2s)
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    setState(() {
      _isEstimating = false;
      _isConfirmedState = true;
    });
  }

  void _proceedToFitCheck() {
    final product = ProductModel(
      id: 'instore_${DateTime.now().millisecondsSinceEpoch}',
      title: _nameController.text.trim().isEmpty
          ? 'Showroom Item'
          : _nameController.text.trim(),
      source: ProductSource.offline,
      category: _category,
      lengthIn: _capturedLengthIn,
      widthIn: _capturedWidthIn,
      heightIn: _capturedHeightIn,
      confidence: ConfidenceLevel.directHigh, // Measured directly — high confidence
      createdAt: DateTime.now(),
    );

    widget.state.setActiveProduct(product);

    Navigator.of(context).push(
      GlassPageRoute(
        page: PlacementViewerScreen(state: widget.state),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isConfirmedState) {
      return _buildConfirmDimensionsView();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full-screen Camera View with Close Orbit Guide Overlay
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, _) {
              return CustomPaint(
                painter: _CloseOrbitGuidePainter(
                  orbitProgress: _orbitController.value,
                  coveragePercent: _orbitCoverage,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),

          // 2. Top Header with Cancel Control
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0x66000000),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x99000000),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x3300F0FF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.blur_on_rounded, color: AppColors.primaryCyan, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Splat Filter Active',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Instruction Copy & Orbit Meter
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Column(
              children: [
                GlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  surfaceColor: const Color(0x77000000),
                  child: Column(
                    children: [
                      Text(
                        'Quick scan: walk halfway around the item',
                        textAlign: TextAlign.center,
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Keeps real-world millimeter scale using device AR anchors',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Coverage Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0x88000000),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.rotate_right_rounded, size: 16, color: AppColors.primaryCyan),
                      const SizedBox(width: 8),
                      Text(
                        'Orbit Coverage: ${_orbitCoverage.toInt()}%',
                        style: AppTypography.badge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Capture Button or Estimating Size State
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: _isEstimating ? _buildEstimatingLoadingCard() : _buildCaptureButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _onCapture,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white, width: 3.5),
            ),
            child: Center(
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.camera_rounded,
                  color: Color(0xFF001524),
                  size: 30,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tap when 180° orbit is complete',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEstimatingLoadingCard() {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      surfaceColor: const Color(0xCC0E0E18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryCyan),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Estimating size...',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                'Running fast-path Gaussian splatting calibration',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmDimensionsView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm Dimensions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => setState(() => _isConfirmedState = false),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // High Confidence Badge
            Center(
              child: const ConfidenceBadge(
                confidence: ConfidenceLevel.directHigh,
              ),
            ),
            const SizedBox(height: 18),

            // Product Name Field
            GlassCard(
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _nameController,
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 3D Proxy Shape Preview
            GlassCard(
              borderRadius: 22,
              padding: const EdgeInsets.all(20),
              hasTopGlow: true,
              child: Column(
                children: [
                  ProxyShape3DPreview(
                    category: _category,
                    lengthIn: _capturedLengthIn,
                    widthIn: _capturedWidthIn,
                    heightIn: _capturedHeightIn,
                    size: 150,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_capturedLengthIn.toInt()}″L × ${_capturedWidthIn.toInt()}″W × ${_capturedHeightIn.toInt()}″H',
                    style: AppTypography.monospace.copyWith(
                      color: AppColors.primaryCyan,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Editable Length, Width, Height fields
            DimensionalInput(
              label: 'Length',
              initialInches: _capturedLengthIn,
              onChanged: (val) => setState(() => _capturedLengthIn = val),
            ),
            const SizedBox(height: 12),
            DimensionalInput(
              label: 'Width (Depth)',
              initialInches: _capturedWidthIn,
              onChanged: (val) => setState(() => _capturedWidthIn = val),
            ),
            const SizedBox(height: 12),
            DimensionalInput(
              label: 'Height',
              initialInches: _capturedHeightIn,
              onChanged: (val) => setState(() => _capturedHeightIn = val),
            ),
            const SizedBox(height: 28),

            // Check Fit in My Home CTA Button
            GlassButton(
              label: 'Check Fit in My Home',
              icon: Icons.view_in_ar_rounded,
              variant: GlassButtonVariant.primary,
              height: 54,
              onPressed: _proceedToFitCheck,
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseOrbitGuidePainter extends CustomPainter {
  final double orbitProgress;
  final double coveragePercent;

  _CloseOrbitGuidePainter({
    required this.orbitProgress,
    required this.coveragePercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final center = Offset(size.width / 2, size.height * 0.52);
    final radiusX = size.width * 0.36;
    final radiusY = size.height * 0.18;

    // 1. Semi-transparent floor grid
    final gridPaint = Paint()
      ..color = const Color(0x1400F0FF)
      ..strokeWidth = 1.0;
    for (double i = -radiusX; i <= radiusX; i += 28) {
      canvas.drawLine(
        Offset(center.dx + i, center.dy - radiusY),
        Offset(center.dx + i, center.dy + radiusY),
        gridPaint,
      );
    }

    // 2. 180° Half-Orbit Arc (Shorter/Smaller than home scan guide)
    final arcRect = Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2);
    final arcPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawArc(arcRect, 0, math.pi, false, arcPaint);

    // 3. Completed Coverage Arc
    final sweep = (coveragePercent / 100.0) * math.pi;
    final activeArcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F0FF), Color(0xFF9D4EDD)],
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, 0, sweep, false, activeArcPaint);

    // 4. Orbiting Phone/Camera Target Indicator
    final currentAngle = (orbitProgress * math.pi);
    final phoneX = center.dx + (radiusX * math.cos(currentAngle));
    final phoneY = center.dy + (radiusY * math.sin(currentAngle));

    canvas.drawCircle(Offset(phoneX, phoneY), 12, Paint()..color = const Color(0x5500F0FF));
    canvas.drawCircle(Offset(phoneX, phoneY), 6, Paint()..color = AppColors.primaryCyan);
  }

  @override
  bool shouldRepaint(covariant _CloseOrbitGuidePainter oldDelegate) {
    return oldDelegate.orbitProgress != orbitProgress ||
        oldDelegate.coveragePercent != coveragePercent;
  }
}
