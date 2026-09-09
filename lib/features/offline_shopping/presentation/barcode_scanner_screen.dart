import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/product_model.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_button.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/page_transitions.dart';
import 'barcode_result_screen.dart';
import 'in_store_camera_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final RoomFitState state;

  const BarcodeScannerScreen({super.key, required this.state});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _triggerScanResult({required bool simulateMatch}) {
    ProductModel? matchedProduct;

    if (simulateMatch) {
      // Matched state with amber packaging confidence flag
      matchedProduct = ProductModel(
        id: 'barcode_match_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Bjursta Extendable Dining Table',
        source: ProductSource.offline,
        category: ProductCategory.table,
        lengthIn: 68.0,
        widthIn: 34.0,
        heightIn: 29.5,
        confidence: ConfidenceLevel.packagingAmber,
        barcode: '7318540023412',
        createdAt: DateTime.now(),
      );
    } else {
      // Unmatched state with red flag
      matchedProduct = null;
    }

    Navigator.of(context).pushReplacement(
      GlassPageRoute(
        page: BarcodeResultScreen(
          state: widget.state,
          matchedProduct: matchedProduct,
          scannedCode: simulateMatch ? '7318540023412' : '0949221849104',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated camera view with laser line
          AnimatedBuilder(
            animation: _laserController,
            builder: (context, _) {
              return CustomPaint(
                painter: _BarcodeViewfinderPainter(
                  laserProgress: _laserController.value,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),

          // Header
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
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.flash_on_rounded, color: AppColors.primaryCyan, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Flash Auto',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Prompt text
          Positioned(
            top: 140,
            left: 20,
            right: 20,
            child: Center(
              child: GlassCard(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                surfaceColor: const Color(0x66000000),
                child: Text(
                  'Align barcode within frame to scan',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Test Controls (Lets user simulate both states of Prompt 6)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: GlassCard(
              borderRadius: 22,
              padding: const EdgeInsets.all(16),
              surfaceColor: const Color(0x6614141E),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Simulate Barcode Scan Result:',
                    style: AppTypography.label.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: 'Simulate Match (Amber)',
                          variant: GlassButtonVariant.primary,
                          height: 44,
                          onPressed: () => _triggerScanResult(simulateMatch: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GlassButton(
                          label: 'No Match (Red)',
                          variant: GlassButtonVariant.danger,
                          height: 44,
                          onPressed: () => _triggerScanResult(simulateMatch: false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodeViewfinderPainter extends CustomPainter {
  final double laserProgress;

  _BarcodeViewfinderPainter({required this.laserProgress});

  @override
  void paint(Canvas canvas, Size size) {
    // Background dark tint
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xCC000000),
    );

    // Viewfinder Cutout
    final frameW = size.width * 0.76;
    final frameH = frameW * 0.65;
    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.45),
      width: frameW,
      height: frameH,
    );

    // Clear cutout inside
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(16)),
      Paint()..blendMode = BlendMode.clear,
    );

    // Corner brackets
    final cornerPaint = Paint()
      ..color = AppColors.primaryCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    const cornerLen = 28.0;
    // Top-left
    canvas.drawLine(frameRect.topLeft, frameRect.topLeft.translate(cornerLen, 0), cornerPaint);
    canvas.drawLine(frameRect.topLeft, frameRect.topLeft.translate(0, cornerLen), cornerPaint);

    // Top-right
    canvas.drawLine(frameRect.topRight, frameRect.topRight.translate(-cornerLen, 0), cornerPaint);
    canvas.drawLine(frameRect.topRight, frameRect.topRight.translate(0, cornerLen), cornerPaint);

    // Bottom-left
    canvas.drawLine(frameRect.bottomLeft, frameRect.bottomLeft.translate(cornerLen, 0), cornerPaint);
    canvas.drawLine(frameRect.bottomLeft, frameRect.bottomLeft.translate(0, -cornerLen), cornerPaint);

    // Bottom-right
    canvas.drawLine(frameRect.bottomRight, frameRect.bottomRight.translate(-cornerLen, 0), cornerPaint);
    canvas.drawLine(frameRect.bottomRight, frameRect.bottomRight.translate(0, -cornerLen), cornerPaint);

    // Animated Red/Cyan Laser Sweep
    final laserY = frameRect.top + (frameRect.height * laserProgress);
    final laserPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primaryCyan.withOpacity(0.85),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(frameRect.left, laserY, frameRect.width, 2.5));
    canvas.drawRect(Rect.fromLTWH(frameRect.left, laserY, frameRect.width, 2.5), laserPaint);
  }

  @override
  bool shouldRepaint(covariant _BarcodeViewfinderPainter oldDelegate) {
    return oldDelegate.laserProgress != laserProgress;
  }
}
