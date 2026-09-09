# Code Conventions & Design System Guidelines

## Coding Standards
- **Dart Formats**: Follow official Dart guidelines (`flutter_lints`).
- **Null-Safety**: 100% sound null-safety with non-nullable types unless nullability is semantically required.
- **Immutability**: Domain models (`RoomModel`, `ProductModel`, `FitCheckRecord`, `FitEvaluationResult`) are immutable `@immutable` with `copyWith()` utility methods.

## UI Design System Conventions (OriginOS Glassmorphism)
1. **Background**: Always `#0A0A0F` (`AppColors.background`).
2. **Glass Surfaces**:
   - `GlassCard` wraps `BackdropFilter` with `sigmaX: 20, sigmaY: 20`.
   - Card border: Subtle white/cyan gradient with 16–24px border radius.
   - High-emphasis cards feature `hasTopGlow: true` rendering a linear top-edge specular highlight.
3. **Typography**:
   - Headers use bold weights (`w700`, `w800`) with tight letter spacing (`-0.5`).
   - Dimension numbers and technical codes use monospace styling (`AppTypography.monospace`).
4. **Color Semantics**:
   - Primary Interactive Accent: Electric Cyan (`#00F0FF`) with secondary blue (`#0066FF`).
   - Secondary Interactive Accent: Purple/Violet (`#9D4EDD`) for offline / camera actions.
   - Status Green (`#00E676`): Fits comfortably / High confidence.
   - Status Amber (`#FFB300`): Tight fit / Packaging warning / Moderate confidence.
   - Status Red (`#FF3B30`): Won't fit / Obstruction collision / No match.
5. **Page Transitions**: Always use `GlassPageRoute` for route navigation to guarantee smooth fade/scale transitions without jarring default OS wipes.
