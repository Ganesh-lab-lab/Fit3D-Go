# Integrations & External Interfaces

## Device Sensors & AR Interfaces
- **Spatial Room Scanning**:
  - Models ARKit (iOS) / ARCore (Android) plane detection, mesh point-cloud generation, and doorway tag raycasting.
  - In `ScanArCameraScreen`: Simulates real-time perimeter mesh construction, coverage % accumulator, and interactive wall doorway tagging.
- **In-Store Object Capture**:
  - Models 180° semi-orbit spatial photogrammetry / LiDAR capture.
  - In `InStoreCameraScreen`: Real-time orbit guidance overlay, 50% perimeter coverage ring, dimension regression estimator.
- **Barcode & QR Scanner**:
  - Viewfinder with reticle animation and simulated barcode reader resolving UPC/EAN tokens.

## Backend & Web Parsing Interfaces
- **Online Product Link Auto-Detection**:
  - `OnlineProductScreen` provides a parsing interface designed to interface with backend metadata scrapers (OpenGraph, Schema.org `Product` JSON-LD, microdata) with instant demo presets (IKEA, West Elm, CB2, Wayfair).
- **Barcode / UPC Catalog Lookup**:
  - Fast barcode lookup matching known SKUs, returning product metadata, catalog dimensions, and confidence flags.

## Persistence & Storage
- State serialized in memory and structured domain models (`RoomModel`, `ProductModel`, `FitCheckRecord`) ready for local SQLite/Hive persistence or cloud sync.
