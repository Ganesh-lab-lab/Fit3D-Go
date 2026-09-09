# Project Requirements & Feature Matrix

## Status Legend
- `[x]` Implemented & Verified
- `[ ]` Planned / In Progress

---

### Phase 1: Core Design System & App Scaffold
- [x] **REQ-1.1**: Deep dark background `#0A0A0F`, 20px blur glass cards with 16–24px corner radius.
- [x] **REQ-1.2**: Electric cyan primary accent (`#00F0FF`), status accents (Green/Amber/Red).
- [x] **REQ-1.3**: Bold geometric typography system.
- [x] **REQ-1.4**: Frosted bottom nav bar, custom sheet modal utilities, and soft fade/blur transitions.

### Phase 2: Home Hub
- [x] **REQ-2.1**: Dynamic status card showing "Your Home: X rooms scanned" (or "Scan your home to get started" with CTA).
- [x] **REQ-2.2**: Two equal glass cards for Online Shopping and Offline Shopping.
- [x] **REQ-2.3**: Quick access previews for saved rooms and recent fit checks.

### Phase 3: Spatial Room Scanning Flow
- [x] **REQ-3.1**: Screen 1 with walking perimeter explanation diagram.
- [x] **REQ-3.2**: Screen 2 with live AR camera feed, real-time mesh accumulation, coverage tracker, and tap-to-tag doorway tagging.
- [x] **REQ-3.3**: Screen 3 summary screen with editable room name, dimensions (L x W, ceiling height), Save and "Add Another Room".

### Phase 4: My Home Saved Rooms Library
- [x] **REQ-4.1**: List of scanned rooms as glass cards with mesh/floor plan thumbnails.
- [x] **REQ-4.2**: Room name, dimensions, last-scanned date, and rescan action button.
- [x] **REQ-4.3**: "Add Room" action button.

### Phase 5: Online Shopping & 3D Proxy Generation
- [x] **REQ-5.1**: "Paste product link" field with automated measurement detection.
- [x] **REQ-5.2**: Manual fallback with Length, Width, and Height numeric inputs with unit toggle.
- [x] **REQ-5.3**: Category dropdown (`Sofa`, `Table`, `Lamp`, `Shelf`, `Other`) driving 3D proxy shape.
- [x] **REQ-5.4**: Dynamic 3D preview thumbnail and "Check Fit in My Home" button.

### Phase 6: 3D Spatial Placement Viewer & Collision Engine
- [x] **REQ-6.1**: 3D spatial room canvas rendering walls, doorway cutouts, floor grid, and proxy item.
- [x] **REQ-6.2**: Real-time object drag repositioning, 360° rotation slider, and position reset.
- [x] **REQ-6.3**: Semi-transparent rendering when colliding with walls or blocking doors.
- [x] **REQ-6.4**: Dynamic fit-result banner:
  - Green "Fits comfortably" (+clearance in inches).
  - Amber "Tight fit" (tightest distance called out).
  - Red "Won't fit here" (specific obstruction name).
- [x] **REQ-6.5**: "Save to Wishlist" persistence trigger.

---

### Phase 7: Barcode / QR Lookup with Confidence Flagging (Next Priority)
- [ ] **REQ-7.1**: Entry choice screen with "Scan Barcode / QR" and "Scan with Camera", plus packaging advisory note.
- [ ] **REQ-7.2**: Real-time barcode/QR scanner viewfinder with reticle, flash toggle, and mock barcode triggers.
- [ ] **REQ-7.3**: Amber Confidence Banner for packaging-sourced data on furniture items:
  - Header: "May be packaging size — confirm with camera scan?"
  - Primary CTA: "Scan to Verify".
  - Secondary CTA: "Use these dimensions anyway".
- [ ] **REQ-7.4**: Red No-Match Banner for unregistered barcodes:
  - Header: "No dimensions found for this barcode".
  - Primary CTA: Prominent "Scan with Camera Instead".

### Phase 8: Fast In-Store Camera Capture
- [ ] **REQ-8.1**: Full-screen camera viewfinder with 180° close orbit guide overlay.
- [ ] **REQ-8.2**: Coverage percentage indicator and "Quick scan: walk halfway around the item" copy.
- [ ] **REQ-8.3**: Capture button, cancel control, and animated "Estimating size..." loading state.
- [ ] **REQ-8.4**: Confirm-dimensions sheet with editable L/W/H fields and "Measured directly — high confidence" badge.

### Phase 9: Wishlist & Saved Fit-Checks Library
- [ ] **REQ-9.1**: Saved fit-check glass cards with 3D thumbnail, source tag (Online/Offline), fit badge, confidence indicator, room, and date.
- [ ] **REQ-9.2**: Filter row by fit result (All, Fits, Tight, Won't Fit).
- [ ] **REQ-9.3**: Filter row by room (All Rooms, individual scanned rooms).
- [ ] **REQ-9.4**: Tapping any card reopens the 3D Placement Viewer at the exact saved coordinates and rotation.
