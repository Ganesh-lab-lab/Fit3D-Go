import 'package:flutter/material.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/page_transitions.dart';
import 'barcode_scanner_screen.dart';
import 'in_store_camera_screen.dart';

class OfflineEntryScreen extends StatelessWidget {
  final RoomFitState state;

  const OfflineEntryScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('In-Store Fit Check'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How would you like to measure this item?',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose barcode lookup for quick packaging stats, or camera scan for direct real-world measurements.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),

              // Option 1: Scan Barcode / QR (Prompt 5 requirement)
              GlassCard(
                borderRadius: 22,
                padding: const EdgeInsets.all(22),
                hasTopGlow: true,
                onTap: () {
                  Navigator.of(context).push(
                    GlassPageRoute(
                      page: BarcodeScannerScreen(state: state),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0x2200F0FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x4400F0FF)),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.primaryCyan,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Barcode / QR',
                            style: AppTypography.titleLarge.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Fastest — looks up official dimensions',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Option 2: Scan with Camera (Prompt 5 requirement)
              GlassCard(
                borderRadius: 22,
                padding: const EdgeInsets.all(22),
                hasTopGlow: true,
                borderGradient: const LinearGradient(
                  colors: [Color(0x809D4EDD), Color(0x2200F0FF)],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    GlassPageRoute(
                      page: InStoreCameraScreen(state: state),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0x229D4EDD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x449D4EDD)),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFFD08CFF),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan with Camera',
                            style: AppTypography.titleLarge.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Measures the real object in front of you',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Recommendation note below (Prompt 5 requirement)
              GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(18),
                surfaceColor: const Color(0x1FFFBA08),
                borderColor: const Color(0x44FFBA08),
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
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.statusAmber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pro Tip for In-Store Shopping',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.statusAmber,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'We recommend camera scan for furniture and large items, since listed sizes are often the packaging, not the product.',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFFE2E4EE),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
