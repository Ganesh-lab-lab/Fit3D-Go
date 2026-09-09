# Technology Stack & Environment

## Core Application
- **Framework**: Flutter 3.x (SDK: `>=3.0.0 <4.0.0`)
- **Language**: Dart 3.x (Sound null-safety enabled)
- **Target Platform**: Mobile-first (iOS & Android) with interactive web simulation (`web_preview/index.html`)
- **Package Manager**: Pub (`pubspec.yaml`)

## Dependencies
- `flutter`: Core SDK
- `cupertino_icons`: `^1.0.6`
- `flutter_test`: SDK test harness
- `flutter_lints`: `^3.0.0`

## State & Architecture Model
- **State Management**: `ChangeNotifier` / `AnimatedBuilder` reactive single-source-of-truth pattern (`RoomFitState`)
- **Mathematical Compute Engine**: Pure Dart geometric collision and 3D spatial projection engine (`FitEngine`)
- **Styling Architecture**: Custom Vanilla Glassmorphic Design System (`AppColors`, `AppTypography`, `GlassCard`, `GlassButton`, `GlassBottomBar`, `GlassSheet`) inspired by Vivo/iQOO OriginOS.

## Python / Backend Tooling (Configured for future & local services)
- Python 3.14 runtime available locally (`C:\Users\SCTS\AppData\Local\Programs\Python\Python314\python.exe`)
- Planned / Target Backend: Python / FastAPI backend for product URL dimension parsing, re-localization persistence, and product UPC catalog integration.
