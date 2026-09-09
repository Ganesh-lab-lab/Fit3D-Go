# Phase 9 Plan: Wishlist & Spatial Fit-Checks Library

## Objective
Implement and verify the full Wishlist feature under `/lib/features/wishlist/`, persisting previously saved fit-checks (product thumbnail, source tag Online/Offline, fit-result badge Fits/Tight/Won't Fit, confidence indicator, room checked against, date), providing interactive filters by fit status and room, and reopening the 3D Placement Viewer at the exact saved coordinates and rotation. Wire client persistence to backend endpoints.

---

## Tasks Breakdown

### Task 1: Backend Wishlist Persistence Endpoints
- **Target File**: `backend/services/wishlist_service.py`, `backend/main.py`
- **Actions**:
  - Expose `GET /api/wishlist` with optional query params `fit_status` and `room_id`.
  - Expose `POST /api/wishlist` for inserting newly placed furniture fit evaluations.
  - Expose `DELETE /api/wishlist/{item_id}` for removing saved checks.

### Task 2: Wishlist Screen & Interactive Filters (`REQ-9.1` - `REQ-9.4`)
- **Target File**: `lib/features/wishlist/presentation/wishlist_screen.dart`
- **Actions**:
  - Dual horizontal filter bar:
    * Filter chips by fit status (`All Results`, `Fits`, `Tight`, `Won't Fit`).
    * Filter chips by room (`All Rooms`, `Living Room`, `Bedroom`, etc.).
  - Glass cards rendering:
    * 3D isometric proxy preview thumbnail.
    * Source chip (`Online` / `Offline`).
    * Fit-result pill (`Fits`, `Tight`, `Won't Fit`).
    * Confidence indicator (`directHigh` vs `packagingAmber`).
    * Room checked against and relative timestamp.
  - Interactive tap: restores `RoomFitState` coordinates `(posX, posY, rotationDeg)` and reopens `PlacementViewerScreen`.

### Task 3: Fit-Check "Save to Wishlist" Wiring
- **Target File**: `lib/features/fit_check/presentation/placement_viewer_screen.dart`
- **Actions**:
  - Tapping "Save to Wishlist" generates a `FitCheckRecord` with current position and room context.
  - Calls `state.saveFitCheck(record)`, displays confirmation snackbar, and updates wishlist repository.

---

## Verification Criteria
- [ ] Wishlist screen displays saved items with OriginOS glassmorphic cards.
- [ ] Filtering by fit status dynamically filters visible cards.
- [ ] Filtering by room dynamically filters visible cards.
- [ ] Tapping any wishlist card restores exact X, Y, and rotation in the 3D Placement Viewer.
- [ ] Backend endpoints successfully persist and retrieve wishlist records.
