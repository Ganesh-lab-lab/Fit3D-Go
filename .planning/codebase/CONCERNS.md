# Technical Concerns & Risk Analysis

## High-Risk Areas & Mitigations

### 1. Camera & AR Sensor Robustness
- **Risk**: Device AR tracking loss (poor lighting, featureless walls, specular floor reflections) can produce degraded or non-convex mesh polygons.
- **Mitigation**: The app isolates mesh generation through simulated safe polygon anchors with sanity-checking bounds and provides immediate fallback to editable manual room dimensions (`ScanSummaryScreen`).

### 2. Barcode Packaging vs Real Item Dimensions
- **Risk**: Retail UPC/EAN databases commonly register shipping box dimensions rather than actual unpacked product dimensions. If used blindly, furniture will report as "Won't fit" when it actually fits, or vice versa.
- **Mitigation**: Prompt 6 & Prompt 7 explicit confidence flagging: Amber banner alert, default recommendation to verify with direct camera scan (`InStoreCameraScreen`), and visible confidence badge on all downstream fit-check screens.

### 3. AR / Canvas Rendering Performance
- **Risk**: Continuous re-rendering of extruded 3D geometry during rapid touch drag or 360-degree rotation can drop frames on lower-end mobile chipsets.
- **Mitigation**: Geometry matrices are calculated on `shouldRepaint` triggers only when offsets or rotation degrees change. Drawing loops use pre-allocated `Path` and `Paint` caches rather than allocating inside the render loop.

### 4. Backend Synchronization & Re-localization
- **Risk**: Offline shopping in basements or store warehouses with weak cell reception.
- **Mitigation**: Room profiles and wishlist items are stored locally on device. Online lookups gracefully fall back to local proxy category presets.
