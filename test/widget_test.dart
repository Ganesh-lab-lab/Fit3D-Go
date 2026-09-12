import 'package:flutter_test/flutter_test.dart';
import 'package:roomfit/core/models/room_model.dart';
import 'package:roomfit/core/models/product_model.dart';
import 'package:roomfit/core/models/fit_check_record.dart';

void main() {
  group('RoomFit Model Serialization Tests', () {
    test('RoomModel toJson and fromJson round-trip', () {
      final now = DateTime.now();
      final room = RoomModel(
        id: 'test_r1',
        name: 'Master Suite',
        lengthFt: 18.5,
        widthFt: 14.2,
        ceilingHeightFt: 10.0,
        scannedDate: now,
        doorways: const [
          DoorwayMarker(id: 'd1', wallIndex: 1, normalizedOffset: 0.4, widthFt: 3.0),
        ],
        thumbnailSeed: 42,
      );

      final json = room.toJson();
      expect(json['id'], 'test_r1');
      expect(json['name'], 'Master Suite');
      expect(json['length_ft'], 18.5);
      expect(json['width_ft'], 14.2);
      expect(json['doorways'], isNotEmpty);

      final restored = RoomModel.fromJson(json);
      expect(restored.id, room.id);
      expect(restored.name, room.name);
      expect(restored.lengthFt, room.lengthFt);
      expect(restored.widthFt, room.widthFt);
      expect(restored.doorways.length, 1);
      expect(restored.doorways.first.id, 'd1');
    });

    test('ProductModel toJson and fromJson round-trip', () {
      final now = DateTime.now();
      final product = ProductModel(
        id: 'prod_test',
        title: 'Modern Coffee Table',
        source: ProductSource.online,
        category: ProductCategory.table,
        lengthIn: 48.0,
        widthIn: 24.0,
        heightIn: 18.0,
        confidence: ConfidenceLevel.directHigh,
        createdAt: now,
      );

      final json = product.toJson();
      expect(json['title'], 'Modern Coffee Table');
      expect(json['source'], 'online');
      expect(json['category'], 'table');
      expect(json['confidence'], 'directHigh');

      final restored = ProductModel.fromJson(json);
      expect(restored.id, product.id);
      expect(restored.title, product.title);
      expect(restored.source, ProductSource.online);
      expect(restored.category, ProductCategory.table);
      expect(restored.lengthIn, 48.0);
    });

    test('FitCheckRecord toJson and fromJson round-trip', () {
      final now = DateTime.now();
      final product = ProductModel(
        id: 'prod_fit',
        title: 'Armchair',
        source: ProductSource.offline,
        category: ProductCategory.sofa,
        lengthIn: 34.0,
        widthIn: 32.0,
        heightIn: 35.0,
        confidence: ConfidenceLevel.packagingAmber,
        createdAt: now,
      );

      final record = FitCheckRecord(
        id: 'fit_test_1',
        product: product,
        roomId: 'room_1',
        roomName: 'Living Room',
        positionX: 0.25,
        positionY: -0.15,
        rotationDeg: 45.0,
        fitStatus: FitStatus.tight,
        clearanceInches: 3.5,
        obstructionReason: 'Near wall',
        timestamp: now,
      );

      final json = record.toJson();
      expect(json['product_id'], 'prod_fit');
      expect(json['fit_status'], 'tight');
      expect(json['position_x'], 0.25);

      final restored = FitCheckRecord.fromJson(json);
      expect(restored.id, record.id);
      expect(restored.product.title, 'Armchair');
      expect(restored.fitStatus, FitStatus.tight);
      expect(restored.clearanceInches, 3.5);
    });
  });
}
