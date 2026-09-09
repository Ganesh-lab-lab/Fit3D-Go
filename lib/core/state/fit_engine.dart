import 'dart:math' as math;
import '../models/fit_check_record.dart';
import '../models/product_model.dart';
import '../models/room_model.dart';

class FitEvaluationResult {
  final FitStatus status;
  final double clearanceInches;
  final String description;
  final String? obstructionReason;
  final bool isDoorwayObstructed;
  final bool isWallCollision;

  const FitEvaluationResult({
    required this.status,
    required this.clearanceInches,
    required this.description,
    this.obstructionReason,
    this.isDoorwayObstructed = false,
    this.isWallCollision = false,
  });
}

class FitEngine {
  FitEngine._();

  /// Evaluates the real-time fit of a product placed inside a room at (posX, posY)
  /// with a given rotationDeg.
  /// [posX] and [posY] are normalized from -0.85 to +0.85 relative to room dimensions.
  static FitEvaluationResult evaluate({
    required RoomModel room,
    required ProductModel product,
    required double posX,
    required double posY,
    required double rotationDeg,
  }) {
    final double roomLenIn = room.lengthFt * 12.0; // Y axis total inches
    final double roomWidIn = room.widthFt * 12.0;  // X axis total inches

    final double halfRoomX = roomWidIn / 2.0;
    final double halfRoomY = roomLenIn / 2.0;

    // Center of product in room inches coordinate space
    final double centerInX = posX * halfRoomX;
    final double centerInY = posY * halfRoomY;

    // Product bounding box half-extents (before rotation)
    final double halfProdW = product.widthIn / 2.0;
    final double halfProdL = product.lengthIn / 2.0;

    // Rotate 4 corners of product
    final double rad = rotationDeg * (math.pi / 180.0);
    final double cosA = math.cos(rad);
    final double sinA = math.sin(rad);

    final List<math.Point<double>> localCorners = [
      math.Point(-halfProdW, -halfProdL),
      math.Point(halfProdW, -halfProdL),
      math.Point(halfProdW, halfProdL),
      math.Point(-halfProdW, halfProdL),
    ];

    final List<math.Point<double>> worldCorners = localCorners.map((pt) {
      final rx = pt.x * cosA - pt.y * sinA;
      final ry = pt.x * sinA + pt.y * cosA;
      return math.Point(centerInX + rx, centerInY + ry);
    }).toList();

    // 1. Check Wall collisions
    double minWallClearance = double.infinity;
    String? wallObstruction;

    for (final corner in worldCorners) {
      // West wall (x = -halfRoomX)
      final westClearance = corner.x - (-halfRoomX);
      if (westClearance < 0 && wallObstruction == null) {
        wallObstruction = 'Collides with West wall';
      }
      if (westClearance < minWallClearance) minWallClearance = westClearance;

      // East wall (x = +halfRoomX)
      final eastClearance = halfRoomX - corner.x;
      if (eastClearance < 0 && wallObstruction == null) {
        wallObstruction = 'Collides with East wall';
      }
      if (eastClearance < minWallClearance) minWallClearance = eastClearance;

      // South wall (y = -halfRoomY)
      final southClearance = corner.y - (-halfRoomY);
      if (southClearance < 0 && wallObstruction == null) {
        wallObstruction = 'Collides with South wall';
      }
      if (southClearance < minWallClearance) minWallClearance = southClearance;

      // North wall (y = +halfRoomY)
      final northClearance = halfRoomY - corner.y;
      if (northClearance < 0 && wallObstruction == null) {
        wallObstruction = 'Collides with North wall';
      }
      if (northClearance < minWallClearance) minWallClearance = northClearance;
    }

    // 2. Check Doorway clearance & obstructions
    bool blocksDoor = false;
    double minDoorClearance = double.infinity;

    for (final door in room.doorways) {
      // Calculate door center in inches
      double doorX = 0;
      double doorY = 0;
      final doorWidthIn = door.widthFt * 12.0;

      if (door.wallIndex == 0) {
        // North wall
        doorY = halfRoomY;
        doorX = -halfRoomX + (door.normalizedOffset * roomWidIn);
      } else if (door.wallIndex == 1) {
        // East wall
        doorX = halfRoomX;
        doorY = -halfRoomY + (door.normalizedOffset * roomLenIn);
      } else if (door.wallIndex == 2) {
        // South wall
        doorY = -halfRoomY;
        doorX = -halfRoomX + (door.normalizedOffset * roomWidIn);
      } else {
        // West wall
        doorX = -halfRoomX;
        doorY = -halfRoomY + (door.normalizedOffset * roomLenIn);
      }

      // Check distance from product center or corners to door entry zone (36" buffer zone)
      final distToDoorCenter = math.sqrt(
        math.pow(centerInX - doorX, 2) + math.pow(centerInY - doorY, 2),
      );

      final clearance = distToDoorCenter - (math.max(halfProdW, halfProdL) + (doorWidthIn / 2));
      if (clearance < minDoorClearance) minDoorClearance = clearance;

      // If product is closer than 16 inches to doorway entry threshold:
      if (distToDoorCenter < (math.max(halfProdW, halfProdL) + 12)) {
        blocksDoor = true;
      }
    }

    final double overallClearance = math.min(minWallClearance, minDoorClearance);

    // 3. Resolve Fit Status
    if (blocksDoor) {
      return FitEvaluationResult(
        status: FitStatus.wontFit,
        clearanceInches: math.max(0, overallClearance),
        description: "Won't fit here: Blocks doorway",
        obstructionReason: 'Blocks doorway',
        isDoorwayObstructed: true,
      );
    }

    if (minWallClearance < 0) {
      return FitEvaluationResult(
        status: FitStatus.wontFit,
        clearanceInches: 0.0,
        description: "Won't fit here: ${wallObstruction ?? 'Wall collision'}",
        obstructionReason: wallObstruction ?? 'Wall collision',
        isWallCollision: true,
      );
    }

    if (overallClearance < 8.0) {
      final detail = minDoorClearance < minWallClearance
          ? '${overallClearance.toStringAsFixed(1)}" to doorway'
          : '${overallClearance.toStringAsFixed(1)}" to wall';
      return FitEvaluationResult(
        status: FitStatus.tight,
        clearanceInches: overallClearance,
        description: 'Tight fit: $detail',
        obstructionReason: 'Tight clearance ($detail)',
      );
    }

    return FitEvaluationResult(
      status: FitStatus.fits,
      clearanceInches: overallClearance,
      description: 'Fits comfortably: +${overallClearance.toStringAsFixed(1)}" clearance',
    );
  }
}
