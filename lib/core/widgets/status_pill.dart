import 'package:flutter/material.dart';
import '../models/fit_check_record.dart';
import '../theme/app_typography.dart';

class StatusPill extends StatelessWidget {
  final FitStatus status;
  final bool isCompact;

  const StatusPill({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(status.statusColorHex);
    final bgColor = Color(status.bgColorHex);

    IconData icon;
    switch (status) {
      case FitStatus.fits:
        icon = Icons.check_circle_rounded;
        break;
      case FitStatus.tight:
        icon = Icons.warning_rounded;
        break;
      case FitStatus.wontFit:
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 13 : 15, color: color),
          const SizedBox(width: 5),
          Text(
            isCompact ? status.shortLabel : status.label,
            style: AppTypography.badge.copyWith(
              color: color,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
