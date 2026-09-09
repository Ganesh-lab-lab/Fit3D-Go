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

class InStoreCameraScreen extends StatefulWidget {
  final RoomFitState state;
  final ProductCategory prefillCategory;

  const InStoreCameraScreen({
    super.key,
    required this.state,
    this.prefillCategory = ProductCategory.sofa,
  });

  @override
  State<InStoreCameraScreen> createState() => _InStoreCameraScreenState();
}

class _InStoreCameraScreenState extends State<InStoreCameraScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbitController;
  Timer? _orbitTimer;

  double _orbitCoverage = 20.0; // 0% to 100% (halfway around item = 180 deg)
  bool _isEstimating = false;
  bool _isConfirmedState = false;

  // Captured dimensions (editable in confirm state)
  double _capturedLengthIn = 76.0;
  double _capturedWidthIn = 35.0;
  double _capturedHeightIn = 31.0;
  late ProductCategory _category;
  final TextEditingController _nameController =
      TextEditingController(text: 'In-Store Scanned Item');

  @override
  void initState() {
    super.initState();
    _category = widget.prefillCategory;
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Simulate user walking halfway around item
    _orbitTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted || _isEstimating || _isConfirmedState) return;
      setState(() {
        if (_orbitCoverage < 95.0) {
          _orbitCoverage += 2.2;
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

    // Brief "Estimating size..." loading state (Prompt 7 requirement)
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    setState(() {
      _isEstimating = false;
      _isConfirmedState = true;
    });
  }

  void _proceedToFitCheck() {
    final product = ProductModel(
      id: 'instore_${DateTime.now().millisecondsSinceEpoch}',
      title: _nameController.text.trim().isEmpty ? 'In-Store Item' : _nameController.text.trim(),
      source: ProductSource.offline,
      category: _category,
      lengthIn: _capturedLengthIn,
      widthIn: _capturedWidthIn,
      heightIn: _capturedHeightIn,
      confidence: ConfidenceLevel.directHigh,
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
          // 1. Full-screen Camera View with Close Orbit Guide Overlay (Prompt 7)
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
                  // Coverage Indicator Pill (Prompt 7)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x99000000),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x3300F0FF)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            value: _orbitCoverage / 100.0,
                            strokeWidth: 2.2,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primaryCyan),
                            backgroundColor: const Color(0x33FFFFFF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Orbit: ${(_orbitCoverage * 1.8).toInt()}° / 180°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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

          // 3. Instruction Copy Card (Prompt 7 requirement)
          Positioned(
            top: 90,
            left: 20,
            right: 20,
            child: Center(
              child: GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                surfaceColor: const Color(0x66000000),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.rotate_right_rounded, color: AppColors.primaryCyan, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Quick scan: walk halfway around the item',
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Estimating Size Overlay Loading State (Prompt 7 requirement)
          if (_isEstimating)
            Container(
              color: const Color(0xCC07080D),
              child: Center(
                child: GlassCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          valueColor: AlwaysStoppedAnimation(AppColors.primaryCyan),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Estimating size...',
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Triangulating point cloud & spatial bounding box',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryCyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. Capture Control Button (Prompt 7 requirement)
          if (!_isEstimating)
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Capture Measurements',
                      icon: Icons.camera_rounded,
                      variant: GlassButtonVariant.primary,
                      height: 56,
                      onPressed: _onCapture,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Confirm Dimensions View (Prompt 7 requirement)
  Widget _buildConfirmDimensionsView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm Dimensions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            setState(() {
              _isConfirmedState = false;
              _orbitCoverage = 20.0;
            });
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
          physics: const BouncingScrollPhysics(),
          children: [
            // "Measured directly — high confidence" badge (Prompt 7 requirement)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x2E00E676),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x6600E676)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2000E676),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, color: AppColors.statusGreen, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Measured directly — high confidence',
                      style: AppTypography.badge.copyWith(
                        color: AppColors.statusGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3D Proxy preview
            Center(
              child: GlassCard(
                borderRadius: 22,
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  children: [
                    ProxyShape3DPreview(
                      category: _category,
                      lengthIn: _capturedLengthIn,
                      widthIn: _capturedWidthIn,
                      heightIn: _capturedHeightIn,
                      size: 130,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_capturedLengthIn.toStringAsFixed(1)}"L x ${_capturedWidthIn.toStringAsFixed(1)}"W x ${_capturedHeightIn.toStringAsFixed(1)}"H',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Item Name
            Text('Item Name', style: AppTypography.label),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: AppTypography.titleMedium.copyWith(fontSize: 15),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.edit_note_rounded, color: AppColors.primaryCyan),
              ),
            ),
            const SizedBox(height: 20),

            // Editable Length, Width, Height fields (Prompt 7 requirement)
            Text('Editable Dimensions', style: AppTypography.label),
            const SizedBox(height: 10),
            DimensionalInputRow(
              label: 'Length',
              valueInches: _capturedLengthIn,
              onChanged: (val) => setState(() => _capturedLengthIn = val),
            ),
            const SizedBox(height: 10),
            DimensionalInputRow(
              label: 'Width',
              valueInches: _capturedWidthIn,
              onChanged: (val) => setState(() => _capturedWidthIn = val),
            ),
            const SizedBox(height: 10),
            DimensionalInputRow(
              label: 'Height',
              valueInches: _capturedHeightIn,
              onChanged: (val) => setState(() => _capturedHeightIn = val),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: GlassButton(
          label: 'Check Fit in My Home',
          icon: Icons.view_in_ar_rounded,
          variant: GlassButtonVariant.primary,
          height: 54,
          onPressed: _proceedToFitCheck,
        ),
      ),
    );
  }
}

/// Custom painter for the close orbit circular guide overlay (Prompt 7)
class _CloseOrbitGuidePainter extends CustomPainter {
  final double orbitProgress;
  final double coveragePercent;

  _CloseOrbitGuidePainter({
    required this.orbitProgress,
    required this.coveragePercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dark room background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0C0D12),
    );

    final center = Offset(size.width / 2, size.height * 0.52);

    // Close orbit ellipse (smaller than full-room scan guide)
    final orbitRadiusX = size.width * 0.38;
    final orbitRadiusY = size.height * 0.16;

    // Floor shadow / target pedestal
    final targetPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0x2200F0FF), Colors.transparent],
      ).createShader(Rect.fromCenter(center: center, width: 140, height: 70));
    canvas.drawOval(Rect.fromCenter(center: center, width: 140, height: 70), targetPaint);

    // Elliptical Orbit Track
    final orbitRect = Rect.fromCenter(
      center: center,
      width: orbitRadiusX * 2,
      height: orbitRadiusY * 2,
    );

    final trackPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(orbitRect, trackPaint);

    // Orbit coverage arc (from 0 to 180 degrees)
    final sweepAngle = (coveragePercent / 100.0) * math.pi;
    final arcPaint = Paint()
      ..color = AppColors.primaryCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawArc(orbitRect, 0, sweepAngle, false, arcPaint);

    // Moving camera guide node along orbit
    final curAngle = (orbitProgress * math.pi * 2);
    final nodeX = center.dx + orbitRadiusX * math.cos(curAngle);
    final nodeY = center.dy + orbitRadiusY * math.sin(curAngle);

    final nodePos = Offset(nodeX, nodeY);
    canvas.drawCircle(nodePos, 8, Paint()..color = AppColors.primaryCyan);
    canvas.drawCircle(
      nodePos,
      14,
      Paint()
        ..color = AppColors.primaryCyan.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Ray to center
    canvas.drawLine(
      nodePos,
      center,
      Paint()
        ..color = AppColors.primaryCyan.withOpacity(0.2)
        ..strokeWidth = 1.0,
    );

    // Center 3D Bounding Box Target Reticle
    final boxPaint = Paint()
      ..color = AppColors.primaryCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const boxW = 80.0;
    const boxH = 65.0;
    final bRect = Rect.fromCenter(center: center.translate(0, -boxH * 0.4), width: boxW, height: boxH);
    canvas.drawRRect(RRect.fromRectAndRadius(bRect, const Radius.circular(8)), boxPaint);

    // Corner targeting reticles
    final reticlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;
    const rLen = 12.0;
    canvas.drawLine(bRect.topLeft, bRect.topLeft.translate(rLen, 0), reticlePaint);
    canvas.drawLine(bRect.topLeft, bRect.topLeft.translate(0, rLen), reticlePaint);
    canvas.drawLine(bRect.topRight, bRect.topRight.translate(-rLen, 0), reticlePaint);
    canvas.drawLine(bRect.topRight, bRect.topRight.translate(0, rLen), reticlePaint);
    canvas.drawLine(bRect.bottomLeft, bRect.bottomLeft.translate(rLen, 0), reticlePaint);
    canvas.drawLine(bRect.bottomLeft, bRect.bottomLeft.translate(0, -rLen), reticlePaint);
    canvas.drawLine(bRect.bottomRight, bRect.bottomRight.translate(-rLen, 0), reticlePaint);
    canvas.drawLine(bRect.bottomRight, bRect.bottomRight.translate(0, -rLen), reticlePaint);
  }

  @override
  bool shouldRepaint(covariant _CloseOrbitGuidePainter oldDelegate) {
    return oldDelegate.orbitProgress != orbitProgress ||
        oldDelegate.coveragePercent != coveragePercent;
  }
}
