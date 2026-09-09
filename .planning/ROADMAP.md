# Project Roadmap

## Phase Overview

```
[Phase 1: OriginOS Theme & Design System]   ==== COMPLETE (Prompt 0)
[Phase 2: Home Hub & Status Navigation]     ==== COMPLETE (Prompt 1)
[Phase 3: Spatial Room Scanning Flow]       ==== COMPLETE (Prompt 2)
[Phase 4: My Home Saved Rooms Library]      ==== COMPLETE (Prompt 3)
[Phase 5: Online Product Mode & 3D Proxy]   ==== COMPLETE (Prompt 4)
[Phase 6: 3D Placement Viewer & Collision]  ==== COMPLETE (Prompt 8)
[Phase 7: Barcode / QR Lookup & Confidence] ==== COMPLETE (Prompts 5 & 6)
[Phase 8: Fast In-Store Camera Capture]     ==== COMPLETE (Prompt 7)
[Phase 9: Wishlist & Saved Fit-Checks]      ==== COMPLETE (Prompt 9)
```

---

## Phase Details

### Phase 1 — OriginOS Glassmorphism Theme (Complete)
- Tokens: Background `#0A0A0F`, cyan/blue accents, status accents.
- Components: `GlassCard`, `GlassButton`, `GlassBottomBar`, `GlassSheet`, `GlassPageRoute`.

### Phase 2 — Home Screen (Complete)
- Top status card with room counter.
- Two equal glass cards: Online Shopping and Offline Shopping.

### Phase 3 — Room Scanning Flow (Complete)
- 3-screen wizard: Intro perimeter diagram, live AR mesh overlay, summary with dimensions & save.

### Phase 4 — My Home Library (Complete)
- Scanned room list, custom mesh thumbnail painter, dimensions, rescan icon, Add Room button.

### Phase 5 — Online Product Mode (Complete)
- Link parser, manual dimension steppers, category proxy shape picker, 3D preview.

### Phase 6 — 3D Spatial Placement Viewer (Complete)
- 3D isometric room canvas, live drag/rotate controls, collision detection, green/amber/red status banner.

---

### Phase 7 — Barcode / QR Lookup with Confidence Flagging (Current Target)
- **Goal**: Provide instant in-store UPC/barcode dimension retrieval, identify potential packaging-dimension discrepancies, and provide clear confidence-driven routing.
- **Deliverables**:
  - `offline_entry_screen.dart`: Two entry cards with advisory notice.
  - `barcode_scanner_screen.dart`: Viewfinder reticle simulator.
  - `barcode_result_screen.dart`: Amber packaging banner ("May be packaging size — confirm with camera scan?") with "Scan to Verify" + "Use these dimensions anyway", and Red no-match banner ("No dimensions found for this barcode") with "Scan with Camera Instead".

### Phase 8 — Fast In-Store Camera Capture (Upcoming)
- **Goal**: Enable direct spatial measurement of unpacked showroom furniture via a 180° semi-orbit scan.
- **Deliverables**:
  - `in_store_camera_screen.dart`: Viewfinder with close orbit overlay, coverage tracker, "Estimating size..." transition, confirm-dimensions view with "Measured directly — high confidence" badge.

### Phase 9 — Wishlist & Saved Fit-Checks Library (Upcoming)
- **Goal**: Enable users to save, review, filter, and revisit past spatial fit evaluations.
- **Deliverables**:
  - `wishlist_screen.dart`: Glass cards with 3D thumbnail, source tag, fit status pill, confidence badge, room checked against, date.
  - Filtering by fit status and room.
  - Tapping a card restores exact coordinates and rotation in the 3D Placement Viewer.
