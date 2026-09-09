# Phase 7 Plan: Barcode / QR Lookup with Confidence Flagging

## Objective
Implement and verify the offline retail in-store barcode/QR lookup workflow with explicit confidence grading. Handle manufacturer shipping packaging discrepancies on furniture items, routing users to camera verification when packaging dimensions are suspected, and offering a seamless camera scan fallback when a barcode is unregistered.

---

## Tasks Breakdown

### Task 1: Offline Choice Entry Interface (`REQ-7.1`)
- **Target File**: `lib/features/offline_shopping/presentation/offline_entry_screen.dart`
- **Actions**:
  - Render two equal glass cards: "Scan Barcode / QR" (UPC/QR scanner) and "Scan with Camera" (direct 3D photogrammetry).
  - Add advisory note at bottom: *"We recommend camera scan for furniture and large items, since listed sizes are often the packaging, not the product."*
  - Ensure navigation routes to `BarcodeScannerScreen` and `InStoreCameraScreen` with `GlassPageRoute`.

### Task 2: Barcode Scanner Viewfinder (`REQ-7.2`)
- **Target File**: `lib/features/offline_shopping/presentation/barcode_scanner_screen.dart`
- **Actions**:
  - Viewfinder with animated laser line and corner reticles.
  - Interactive simulator buttons for instant testing:
    * Test Barcode Match (UPC: `7318540023412` - IKEA Bjursta Extendable Table).
    * Test Unregistered Barcode (UPC: `0949221849104` - No match).
  - Proper disposal of `_laserController`.

### Task 3: Barcode Result View & Confidence Routing (`REQ-7.3`, `REQ-7.4`)
- **Target File**: `lib/features/offline_shopping/presentation/barcode_result_screen.dart`
- **Actions**:
  - **State A (Amber Packaging Flag)**:
    * Product name, detected dimensions, and 3D preview proxy.
    * Amber confidence banner: *"May be packaging size — confirm with camera scan?"*
    * Primary CTA: *"Scan to Verify"* -> routes to `InStoreCameraScreen`.
    * Lower-emphasis CTA: *"Use these dimensions anyway"* -> sets active product and navigates to `PlacementViewerScreen`.
  - **State B (Red No-Match Flag)**:
    * Red banner: *"No dimensions found for this barcode"*.
    * Single prominent primary CTA: *"Scan with Camera Instead"* -> replaces route with `InStoreCameraScreen`.

### Task 4: State & Confidence Model Integration
- **Target Files**: `lib/core/models/product_model.dart`, `lib/core/state/roomfit_state.dart`
- **Actions**:
  - Verify `ConfidenceLevel.packagingAmber` flags persist into `ProductModel` and `FitCheckRecord`.
  - Ensure `PlacementViewerScreen` displays low-confidence alert when `product.confidence == ConfidenceLevel.packagingAmber`.

---

## Verification Criteria
- [ ] Tapping "Scan Barcode / QR" opens the scanner viewfinder.
- [ ] Scanning a matched barcode produces the amber packaging warning banner.
- [ ] "Scan to Verify" routes directly to the in-store camera capture flow.
- [ ] "Use these dimensions anyway" routes to the 3D Placement Viewer with the unverified/packaging badge.
- [ ] Scanning an unregistered barcode produces the red no-match banner with "Scan with Camera Instead" as the sole primary action.
- [ ] Code complies with CodeRabbit guidelines (timer disposal, null-safety, no unhandled exceptions).
