import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/glass_card.dart';

class DimensionalInputRow extends StatelessWidget {
  final String label;
  final double valueInches;
  final ValueChanged<double> onChanged;
  final bool isMetric; // true = cm, false = inches

  const DimensionalInputRow({
    super.key,
    required this.label,
    required this.valueInches,
    required this.onChanged,
    this.isMetric = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayVal = isMetric
        ? (valueInches * 2.54).toStringAsFixed(0)
        : valueInches.toStringAsFixed(0);
    final unitLabel = isMetric ? 'cm' : 'in';

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      surfaceColor: AppColors.glassSurface,
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: AppTypography.titleMedium.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // Minus button
          _stepButton(
            icon: Icons.remove,
            onTap: () {
              final step = isMetric ? (1.0 / 2.54) : 1.0;
              final next = (valueInches - step).clamp(6.0, 300.0);
              onChanged(next);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: displayVal,
                      style: AppTypography.titleLarge.copyWith(
                        fontSize: 20,
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' $unitLabel',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Plus button
          _stepButton(
            icon: Icons.add,
            onTap: () {
              final step = isMetric ? (1.0 / 2.54) : 1.0;
              final next = (valueInches + step).clamp(6.0, 300.0);
              onChanged(next);
            },
          ),
        ],
      ),
    );
  }

  Widget _stepButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: AppColors.primaryCyan.withOpacity(0.2),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0x22FFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x33FFFFFF), width: 1),
          ),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
