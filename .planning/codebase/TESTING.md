# Testing Strategy & Test Harness

## Test Framework
- Standard `flutter_test` suite configured in `test/`.
- Unit tests run via `flutter test` or custom Dart test scripts.

## Automated Tests (`test/fit_engine_test.dart`)
- **Center Placement Fit**: Tests default object placement in center of standard room (`status == FitStatus.fits`).
- **Wall Collision Detection**: Tests offset coordinates past room boundary walls, verifying `status == FitStatus.wontFit` and proper wall identification.
- **Doorway Obstruction Checking**: Tests placement overlapping tagged doorway coordinates, verifying obstruction alert ("Blocks doorway").
- **Rotation Mechanics**: Tests 90-degree and 45-degree rotation changes, verifying bounding box recalculation.
- **Clearance Calculation**: Tests tight fit boundaries where clearance is less than 6 inches (`status == FitStatus.tight`).

## Web & Visual Verification Harness (`web_preview/index.html`)
- Standalone zero-dependency HTML5/Canvas/CSS spatial engine simulating all 10 prompt workflows.
- Validates gesture drags, rotation sliders, collision color shifts, and modal sheet interactions.
