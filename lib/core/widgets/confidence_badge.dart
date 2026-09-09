import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../theme/app_typography.dart';

class ConfidenceBadge extends StatelessWidget {
  final ConfidenceLevel confidence;
  final bool isCompact;

  const ConfidenceBadge({
    super.key,
    required this.confidence,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(confidence.badgeColorHex);

    IconData icon;
    switch (confidence) {
      case ConfidenceLevel.directHigh:
        icon = Icons.verified_rounded;
        break;
      case ConfidenceLevel.packagingAmber:
        icon = Icons.error_outline_rounded;
        break;
      case ConfidenceLevel.unverifiedRed:
        icon = Icons.help_outline_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 13 : 15, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              isCompact ? confidence.shortLabel : confidence.label,
              style: AppTypography.badge.copyWith(
                color: color,
                fontSize: isCompact ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
