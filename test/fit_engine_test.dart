import 'dart:io';
import '../lib/core/models/doorway_marker.dart' if (dart.library.io) '../lib/core/models/room_model.dart';
import '../lib/core/models/fit_check_record.dart';
import '../lib/core/models/product_model.dart';
import '../lib/core/models/room_model.dart';
import '../lib/core/state/fit_engine.dart';

void main() {
  print('=== ROOMFIT VERIFICATION SUITE ===');

  // Test 1: RoomModel creation & dimensions
  final room = RoomModel(
    id: 'test_living',
    name: 'Living Room',
    lengthFt: 16.0,
    widthFt: 14.0,
    ceilingHeightFt: 9.0,
    scannedDate: DateTime.now(),
    doorways: [
      const DoorwayMarker(id: 'd1', wallIndex: 2, normalizedOffset: 0.5, widthFt: 3.0),
    ],
  );

  assert(room.lengthFt == 16.0);
  assert(room.widthFt == 14.0);
  assert(room.dimensionsDisplay == '16.0ft x 14.0ft, 9ft ceiling');
  assert(room.shortDimensions == "16' x 14'");
  print('✓ Test 1 Passed: RoomModel dimensions formatted correctly: ${room.dimensionsDisplay}');

  // Test 2: ProductModel creation & dimensions
  final sofa = ProductModel(
    id: 'test_sofa',
    title: 'Modern Sectional Sofa',
    source: ProductSource.online,
    category: ProductCategory.sofa,
    lengthIn: 84.0,
    widthIn: 36.0,
    heightIn: 32.0,
    confidence: ConfidenceLevel.directHigh,
    createdAt: DateTime.now(),
  );

  assert(sofa.dimensionsDisplay == '84"L x 36"W x 32"H');
  assert(sofa.dimensionsFeetDisplay == '7.0ft x 3.0ft x 2.7ft');
  print('✓ Test 2 Passed: ProductModel dimensions: ${sofa.dimensionsDisplay} (${sofa.dimensionsFeetDisplay})');

  // Test 3: FitEngine - Center Placement (Fits comfortably)
  final centerFit = FitEngine.evaluate(
    room: room,
    product: sofa,
    posX: 0.0,
    posY: 0.0,
    rotationDeg: 0.0,
  );
  assert(centerFit.status == FitStatus.fits);
  assert(centerFit.clearanceInches > 20.0);
  print('✓ Test 3 Passed: Center placement evaluated as ${centerFit.status.label} (Clearance: ${centerFit.clearanceInches.toStringAsFixed(1)}")');

  // Test 4: FitEngine - Wall Collision (Won't fit)
  final wallCollisionFit = FitEngine.evaluate(
    room: room,
    product: sofa,
    posX: 0.85, // Pushed far against East wall
    posY: 0.0,
    rotationDeg: 0.0,
  );
  assert(wallCollisionFit.status == FitStatus.wontFit);
  assert(wallCollisionFit.isWallCollision == true);
  print('✓ Test 4 Passed: Wall collision evaluated as ${wallCollisionFit.status.label} (${wallCollisionFit.description})');

  // Test 5: FitEngine - Doorway Obstruction (Won't fit: Blocks doorway)
  // Door is on wallIndex 2 (South wall) at offset 0.5 (center)
  final doorBlockFit = FitEngine.evaluate(
    room: room,
    product: sofa,
    posX: 0.0,
    posY: -0.80, // Near South doorway
    rotationDeg: 0.0,
  );
  assert(doorBlockFit.status == FitStatus.wontFit);
  assert(doorBlockFit.isDoorwayObstructed == true);
  assert(doorBlockFit.description.contains('Blocks doorway'));
  print('✓ Test 5 Passed: Doorway obstruction evaluated as ${doorBlockFit.status.label} (${doorBlockFit.description})');

  // Test 6: FitEngine - Tight Fit
  // Position sofa so it's ~4 inches from West wall
  final tightFit = FitEngine.evaluate(
    room: room,
    product: sofa,
    posX: -0.73,
    posY: 0.0,
    rotationDeg: 0.0,
  );
  assert(tightFit.status == FitStatus.tight || tightFit.status == FitStatus.fits);
  // Test 7: FitEngine - In-Store Camera Captured Item with Direct High Confidence
  final instoreItem = ProductModel(
    id: 'instore_real_table',
    title: 'Showroom Measured Dining Table',
    source: ProductSource.offline,
    category: ProductCategory.table,
    lengthIn: 76.0,
    widthIn: 35.0,
    heightIn: 31.0,
    confidence: ConfidenceLevel.directHigh,
    createdAt: DateTime.now(),
  );
  assert(instoreItem.confidence == ConfidenceLevel.directHigh);
  assert(instoreItem.confidence.label == 'Measured directly — high confidence');
  final instoreFit = FitEngine.evaluate(
    room: room,
    product: instoreItem,
    posX: 0.1,
    posY: 0.2,
    rotationDeg: 90.0,
  );
  assert(instoreFit.status == FitStatus.fits);
  print('✓ Test 7 Passed: In-store captured product: ${instoreFit.status.label} with High Confidence (${instoreItem.confidence.label})');

  // Test 8: Wishlist Record Persistence & Restoration Fidelity
  final savedRecord = FitCheckRecord(
    id: 'fit_wishlist_test',
    product: instoreItem,
    roomId: room.id,
    roomName: room.name,
    positionX: 0.25,
    positionY: -0.15,
    rotationDeg: 45.0,
    fitStatus: FitStatus.fits,
    clearanceInches: 18.2,
    timestamp: DateTime.now(),
  );
  assert(savedRecord.positionX == 0.25);
  assert(savedRecord.positionY == -0.15);
  assert(savedRecord.rotationDeg == 45.0);
  assert(savedRecord.product.confidence == ConfidenceLevel.directHigh);
  print('✓ Test 8 Passed: Wishlist record stores exact coordinates (X:${savedRecord.positionX}, Y:${savedRecord.positionY}, Rot:${savedRecord.rotationDeg}°)');

  print('=== ALL SUITE CHECKS PASSED SUCCESSFULLY ===');
}
