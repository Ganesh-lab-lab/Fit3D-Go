import 'package:flutter/material.dart';
import '../../../core/models/product_model.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_button.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/page_transitions.dart';
import '../../../core/widgets/proxy_shape_3d.dart';
import '../../fit_check/presentation/placement_viewer_screen.dart';
import 'in_store_camera_screen.dart';

class BarcodeResultScreen extends StatelessWidget {
  final RoomFitState state;
  final ProductModel? matchedProduct;
  final String scannedCode;

  const BarcodeResultScreen({
    super.key,
    required this.state,
    required this.matchedProduct,
    required this.scannedCode,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMatch = matchedProduct != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Barcode Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Barcode chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x22FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.primaryCyan),
                    const SizedBox(width: 8),
                    Text(
                      'UPC/EAN: $scannedCode',
                      style: AppTypography.monospace.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (isMatch)
                _buildMatchState(context, matchedProduct!)
              else
                _buildNoMatchState(context),

              const Spacer(),

              // Action Buttons based on Prompt 6 states
              if (isMatch) ...[
                // Primary: Scan to Verify (navigates to in-store camera capture)
                GlassButton(
                  label: 'Scan to Verify',
                  icon: Icons.camera_alt_outlined,
                  variant: GlassButtonVariant.primary,
                  height: 54,
                  width: double.infinity,
                  onPressed: () {
                    Navigator.of(context).push(
                      GlassPageRoute(
                        page: InStoreCameraScreen(
                          state: state,
                          prefillCategory: matchedProduct!.category,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Lower-emphasis option: Use these dimensions anyway
                GlassButton(
                  label: 'Use these dimensions anyway',
                  variant: GlassButtonVariant.ghost,
                  height: 48,
                  width: double.infinity,
                  onPressed: () {
                    state.setActiveProduct(matchedProduct!);
                    Navigator.of(context).push(
                      GlassPageRoute(
                        page: PlacementViewerScreen(state: state),
                      ),
                    );
                  },
                ),
              ] else ...[
                // Prominent "Scan with Camera Instead" as only primary action (Prompt 6)
                GlassButton(
                  label: 'Scan with Camera Instead',
                  icon: Icons.camera_alt_outlined,
                  variant: GlassButtonVariant.primary,
                  height: 54,
                  width: double.infinity,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      GlassPageRoute(
                        page: InStoreCameraScreen(state: state),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  // STATE A: Match Found with Amber Packaging Warning (Prompt 6 requirement)
  Widget _buildMatchState(BuildContext context, ProductModel product) {
    return Column(
      children: [
        // Amber Confidence Banner
        GlassCard(
          borderRadius: 18,
          padding: const EdgeInsets.all(16),
          surfaceColor: const Color(0x2BFFB300),
          borderColor: const Color(0x66FFB300),
          hasTopGlow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0x33FFB300),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.statusAmber,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'May be packaging size — confirm with camera scan?',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.statusAmber,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manufacturer barcodes often report exterior box dimensions. Verify using a quick 3D camera scan for exact furniture fit.',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFFD6D9E6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Product Details Card
        GlassCard(
          borderRadius: 22,
          padding: const EdgeInsets.all(20),
          hasTopGlow: true,
          child: Column(
            children: [
              ProxyShape3DPreview(
                category: product.category,
                lengthIn: product.lengthIn,
                widthIn: product.widthIn,
                heightIn: product.heightIn,
                size: 130,
              ),
              const SizedBox(height: 12),
              Text(
                product.title,
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x22FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  product.dimensionsDisplay,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Footprint: ${product.dimensionsFeetDisplay}',
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STATE B: No match with Red Confidence Banner (Prompt 6 requirement)
  Widget _buildNoMatchState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Red Confidence Banner
        GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          surfaceColor: const Color(0x2EFF3B30),
          borderColor: const Color(0x66FF3B30),
          hasTopGlow: false,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0x33FF3B30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.not_interested_rounded,
                  color: AppColors.statusRed,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No dimensions found for this barcode',
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge.copyWith(
                  color: const Color(0xFFFF5E57),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This product or store-specific SKU is not in our dimension registry. Measure it directly in under 15 seconds using your camera.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFFE2E4EE),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Visual camera measure hint card
        GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0x2200F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.motion_photos_auto_rounded, color: AppColors.primaryCyan),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Direct Spatial Camera Measure',
                      style: AppTypography.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Walk halfway around the item to capture high-confidence measurements',
                      style: AppTypography.bodySmall.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
