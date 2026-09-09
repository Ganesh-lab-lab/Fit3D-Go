# System Architecture

## Architectural Pattern
RoomFit follows a feature-first clean architecture separating domain models, state management, presentation, and custom spatial rendering:

```
lib/
├── core/
│   ├── models/           # Pure domain entities (RoomModel, ProductModel, FitCheckRecord)
│   ├── state/            # Reactive state (RoomFitState) & compute engine (FitEngine)
│   ├── theme/            # OriginOS design system tokens & glass components
│   └── widgets/          # Reusable domain UI components (ProxyShape3D, StatusPill, etc.)
└── features/             # Modular feature screens & presentation components
    ├── home/             # Entry hub & status cards
    ├── scan_room/        # 3-step AR room scanning wizard
    ├── rooms/            # Saved rooms library & mesh thumbnails
    ├── online_shopping/  # Online product URL & manual dimensions input
    ├── offline_shopping/ # Barcode scanner, confidence check & camera capture
    ├── fit_check/        # 3D placement viewer & live collision engine
    └── wishlist/         # Saved checks library & filtering
```

## Spatial Fit-Check Engine (`lib/core/state/fit_engine.dart`)
- **Coordinate System**: Normalized room coordinates `[-1.0, 1.0]` mapped to real physical feet/inches.
- **Collision Mathematics**:
  - Computes 2D oriented bounding boxes (OBB) under arbitrary rotation degrees $\theta$.
  - Wall collision detection tests all 4 corners against room boundary rectangles.
  - Doorway clearance checking evaluates clearance thresholds against user-tagged doorway markers:
    * `clearanceInches < 0`: Collision detected (Red "Won't fit here - Blocks doorway" / "Collides with wall").
    * `0 <= clearanceInches < 6.0`: Tight fit detected (Amber "Tight fit").
    * `clearanceInches >= 6.0`: Comfortable fit (Green "Fits comfortably").

## 3D Isometric Projection (`lib/core/widgets/proxy_shape_3d.dart`, `room_canvas_3d.dart`)
- Isometric transformation matrices project 3D bounding volumes to 2D Canvas with depth sorting, surface illumination gradients, top-glow specular lines, and collision alpha modulation.
