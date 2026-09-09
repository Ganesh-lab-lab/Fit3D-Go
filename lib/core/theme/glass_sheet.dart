import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'glass_card.dart';

/// Shows a frosted glass bottom sheet
Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x99000000),
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0x2E161622),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: Color(0x66FFFFFF), width: 1.2),
                  left: BorderSide(color: Color(0x22FFFFFF), width: 1.0),
                  right: BorderSide(color: Color(0x22FFFFFF), width: 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x88000000),
                    blurRadius: 36,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    // Drag pill indicator
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0x40FFFFFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    builder(ctx),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Frosted modal dialog utility
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: const Color(0xAA000000),
    builder: (ctx) => Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    ),
  );
}
