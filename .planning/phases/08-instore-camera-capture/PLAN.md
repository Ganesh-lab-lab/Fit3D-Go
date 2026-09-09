# Phase 8 Plan: Fast In-Store Camera Capture & Gaussian Splatting Reconstruction

## Objective
Implement the lightweight "quick scan" mode under `/lib/features/instore_capture/` as the high-confidence fallback path when barcode/QR lookup finds no dimensions or returns packaging-only data. Build a fast-path reconstruction backend (reduced Gaussian Splatting iterations / lower resolution target) calibrated to real-world scale using device AR tracking metrics, and wire it to real-time UI with blur-detection and frame spacing.

---

## Tasks Breakdown

### Task 1: Backend Fast-Path Reconstruction Service
- **Target Files**:
  - `backend/services/reconstruction_service.py`
  - `backend/main.py`
- **Actions**:
  - Implement fast-path 3D reconstruction pipeline:
    - Frame-spacing validator (minimum arc displacement between keyframes, e.g. 5°–10° delta).
    - Blur detection filter (Laplacian variance simulation to discard motion-blurred frames).
    - Real-world scale calibration using camera intrinsics and AR tracking raycasts.
    - Reduced-iteration Gaussian Splatting / bounding-box regression algorithm prioritizing sub-second turnaround time.
  - Expose `POST /api/reconstruction/fast-scan` endpoint accepting frame count, orbit angle, and AR scale factor, returning estimated `(length_in, width_in, height_in)`, confidence score, and proxy category.

### Task 2: In-Store Capture Frontend Module (`/lib/features/instore_capture/`)
- **Target Files**:
  - `lib/features/instore_capture/presentation/instore_capture_screen.dart`
  - `lib/features/instore_capture/services/instore_capture_service.dart`
- **Actions**:
  - UI: Full-screen camera view with close orbit guide overlay (180° arc, shorter/smaller than home-scan guide) and coverage indicator.
  - Copy: *"Quick scan: walk halfway around the item"*, capture button, and cancel control styled with OriginOS glassmorphism theme.
  - Animated *"Estimating size..."* loading transition connecting to the fast-path reconstruction service.
  - Confirm-dimensions view with editable Length/Width/Height fields and *"Measured directly — high confidence"* badge (`ConfidenceLevel.directHigh`).
  - Update routing in `offline_entry_screen.dart` and `barcode_result_screen.dart` to link to `/lib/features/instore_capture/`.

### Task 3: Fit-Check Engine Integration
- **Target Files**:
  - `lib/features/instore_capture/presentation/instore_capture_screen.dart`
  - `lib/features/fit_check/presentation/placement_viewer_screen.dart`
- **Actions**:
  - Wire confirmed dimensions directly into `RoomFitState.setActiveProduct()` with `ProductSource.offline` and `ConfidenceLevel.directHigh`.
  - Navigate to `PlacementViewerScreen` with clean `GlassPageRoute`.

---

## Verification Criteria
- [ ] Backend endpoint `POST /api/reconstruction/fast-scan` returns valid scaled dimensions in sub-second time.
- [ ] Full-screen in-store camera capture view renders the close orbit guide (180°) and coverage progress.
- [ ] "Estimating size..." transition simulates Gaussian Splatting turnaround.
- [ ] Confirm-dimensions screen displays editable steppers and `✓ Measured directly — high confidence` badge.
- [ ] Confirmed object flows into 3D Placement Viewer with High confidence badge.
- [ ] Code passes CodeRabbit inspection: no memory leaks, timers cancelled on dispose, mounted checks before setState.
