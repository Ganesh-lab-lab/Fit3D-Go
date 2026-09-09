import 'package:flutter/material.dart';
import '../../../../core/models/fit_check_record.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/state/fit_engine.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/glass_card.dart';

/// Top fit-result banner with Green, Amber, Red states and low-confidence indicator
class FitResultBanner extends StatelessWidget {
  final FitEvaluationResult evaluation;
  final ConfidenceLevel confidence;

  const FitResultBanner({
    super.key,
    required this.evaluation,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    Color bannerColor;
    Color borderColor;
    Color textColor;
    IconData statusIcon;

    switch (evaluation.status) {
      case FitStatus.fits:
        bannerColor = const Color(0x3300E676);
        borderColor = const Color(0x7700E676);
        textColor = AppColors.statusGreen;
        statusIcon = Icons.check_circle_rounded;
        break;
      case FitStatus.tight:
        bannerColor = const Color(0x38FFB300);
        borderColor = const Color(0x88FFB300);
        textColor = AppColors.statusAmber;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case FitStatus.wontFit:
        bannerColor = const Color(0x3DFF3B30);
        borderColor = const Color(0x99FF3B30);
        textColor = const Color(0xFFFF5252);
        statusIcon = Icons.cancel_rounded;
        break;
    }

    final bool isLowConfidence = confidence == ConfidenceLevel.packagingAmber;

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      surfaceColor: bannerColor,
      borderColor: borderColor,
      hasTopGlow: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: textColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evaluation.status.label,
                      style: AppTypography.titleMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      evaluation.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Low-Confidence Warning Indicator (Prompt 8 requirement)
          if (isLowConfidence) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x33FFB300),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x55FFB300)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.statusAmber),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Unverified barcode size — actual furniture fit may vary',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFFFFD54F),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
