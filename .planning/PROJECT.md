# RoomFit / Fit3D Go — Project North Star

## Executive Summary
**RoomFit** is a mobile-only Flutter application inspired by Vivo/iQOO's OriginOS glassmorphic visual language. It allows users to scan their home in high-precision 3D, saving rooms with architectural boundaries and doorway clearance markers. When shopping—whether online via product measurement links or in physical retail stores via barcode lookup and camera scans—RoomFit computes real-time 3D spatial fit-checks against the user's saved home geometry.

## Core Vision & Value Proposition
- **Physical Spatial Truth**: Solves the #1 problem in furniture shopping: buying items that do not fit or block doorways.
- **The Packaging vs. Real Item Problem**: Directly addresses the critical pitfall where manufacturer barcodes report shipping packaging dimensions rather than unpacked furniture sizes, using clear confidence alerts and quick camera capture fallbacks.
- **Visual Excellence**: OriginOS-inspired ultra-refined glassmorphism with deep space dark canvas (`#0A0A0F`), 20px frosted blur, glowing cyan borders, and smooth isometric interactive 3D projections.

## Target User Persona & Platforms
- **Platform**: Flutter mobile (iOS ARKit & Android ARCore) with web verification preview.
- **Primary Users**: Homeowners, interior designers, apartment dwellers, and in-store furniture shoppers seeking instant spatial verification before buying.

## Implemented Baseline (Completed Milestones)
1. **OriginOS Glassmorphic Design System (Prompt 0)**:
   - Complete design tokens in `lib/core/theme/` (`AppColors`, `AppTypography`, `GlassCard`, `GlassButton`, `GlassBottomBar`, `GlassSheet`, `GlassPageRoute`).
2. **Home Hub & Navigation (Prompt 1)**:
   - Dynamic room counter status card ("Your Home: X rooms scanned"), equal-sized Online & Offline shopping cards.
3. **3D Room Scanning Wizard (Prompt 2)**:
   - Intro walking perimeter tutorial, live AR camera mesh overlay with coverage percentage, interactive doorway tap-to-tag, editable summary review and dimension verification.
4. **My Home Saved Rooms Library (Prompt 3)**:
   - Custom floor plan mesh painters, room dimensions summary, rescan actions, and room management.
5. **Online Shopping Mode (Prompt 4)**:
   - URL dimension auto-parser simulation, manual fallback L/W/H steppers, category dropdown for 3D proxy shape generation, and interactive preview.
6. **3D Placement Viewer & Real-Time Collision Engine (Prompt 8 Core)**:
   - 3D isometric room canvas, live object dragging and 360-degree rotation slider with 90-degree snap, green/amber/red fit clearance banner, doorway obstruction alerts.

## Remaining Roadmap & Scope
- **Stage 7**: Barcode / QR Lookup with Confidence Flagging (Prompts 5 & 6)
- **Stage 8**: Fast In-Store Camera Capture (Prompt 7)
- **Stage 9**: Wishlist & Saved Fit-Checks Library (Prompt 9)
