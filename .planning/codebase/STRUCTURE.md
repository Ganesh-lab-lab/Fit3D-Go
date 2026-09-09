# Codebase Structure

## Directory Layout & Key Modules

| Path | Purpose |
| :--- | :--- |
| `lib/main.dart` | Application root, initialization, `RoomFitState` provider, theme wiring |
| `lib/core/models/room_model.dart` | Room entities, dimensions (ft/in), doorway markers, polygon mesh representation |
| `lib/core/models/product_model.dart` | Furniture entities, categories (Sofa, Table, Lamp, Shelf, Other), confidence flags |
| `lib/core/models/fit_check_record.dart` | Placed furniture state, coordinates, rotation, fit result, timestamps |
| `lib/core/state/roomfit_state.dart` | Central ChangeNotifier state container with sample data and persistence operations |
| `lib/core/state/fit_engine.dart` | Core collision and clearance computation logic |
| `lib/core/theme/app_colors.dart` | Palette tokens: `#0A0A0F` dark base, cyan/blue, amber, green, red status colors |
| `lib/core/theme/app_typography.dart` | Bold geometric typography definitions with strict font sizes and weights |
| `lib/core/theme/glass_card.dart` | 20px blur glassmorphic container with customizable top glow, borders, and shadows |
| `lib/core/theme/glass_button.dart` | Primary glowing cyan buttons and secondary frosted controls with press animation |
| `lib/core/theme/glass_bottom_bar.dart` | Floating frosted glass navigation bar |
| `lib/core/theme/glass_sheet.dart` | Modal bottom sheet utilities |
| `lib/core/theme/page_transitions.dart` | Soft fade and blur route transition (`GlassPageRoute`) |
| `lib/core/widgets/confidence_badge.dart` | High confidence vs packaging caution badges |
| `lib/core/widgets/status_pill.dart` | Green / Amber / Red fit status chips |
| `lib/core/widgets/dimensional_input.dart` | Number steppers with unit toggle (Inches / CM) |
| `lib/core/widgets/proxy_shape_3d.dart` | CustomPainter rendering 3D isometric proxy objects |
| `lib/features/home/presentation/home_screen.dart` | Top status card, Online & Offline shopping cards, quick access items |
| `lib/features/scan_room/presentation/` | 3-step scanning wizard (Intro diagram, live AR camera, summary save) |
| `lib/features/rooms/presentation/my_home_screen.dart` | Saved rooms list, floor plan thumbnails, rescan CTA |
| `lib/features/online_shopping/presentation/` | Online product check, URL parser, manual fallback, proxy preview |
| `lib/features/offline_shopping/presentation/` | Barcode vs camera choice, barcode scanner, result screen, in-store camera |
| `lib/features/fit_check/presentation/` | 3D room canvas placement viewer, D-pad & rotation controls, dynamic result banner |
| `lib/features/wishlist/presentation/wishlist_screen.dart` | Saved fit-checks list with dual filters and tap-to-restore placement |
| `web_preview/index.html` | High-fidelity interactive web simulation |
| `test/fit_engine_test.dart` | Unit tests for collision engine, clearances, and boundary conditions |
