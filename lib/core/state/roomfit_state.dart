import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/fit_check_record.dart';
import '../models/product_model.dart';
import '../models/room_model.dart';
import 'fit_engine.dart';

class RoomFitState extends ChangeNotifier {
  final List<RoomModel> _rooms = [];
  final List<FitCheckRecord> _wishlist = [];

  RoomModel? _activeRoom;
  ProductModel? _activeProduct;

  // Real-time placement state
  double _placementX = 0.0;
  double _placementY = 0.0;
  double _rotationDeg = 0.0;

  RoomFitState() {
    _initSeedData();
  }

  List<RoomModel> get rooms => List.unmodifiable(_rooms);
  List<FitCheckRecord> get wishlist => List.unmodifiable(_wishlist);
  RoomModel? get activeRoom => _activeRoom ?? (_rooms.isNotEmpty ? _rooms.first : null);
  ProductModel? get activeProduct => _activeProduct;

  double get placementX => _placementX;
  double get placementY => _placementY;
  double get rotationDeg => _rotationDeg;

  void setActiveRoom(RoomModel room) {
    _activeRoom = room;
    notifyListeners();
  }

  void setActiveProduct(ProductModel product) {
    _activeProduct = product;
    _placementX = 0.0;
    _placementY = 0.0;
    _rotationDeg = 0.0;
    notifyListeners();
  }

  void updatePlacement({double? x, double? y, double? rotation}) {
    if (x != null) _placementX = x.clamp(-0.85, 0.85);
    if (y != null) _placementY = y.clamp(-0.85, 0.85);
    if (rotation != null) _rotationDeg = rotation % 360.0;
    notifyListeners();
  }

  void resetPlacement() {
    _placementX = 0.0;
    _placementY = 0.0;
    _rotationDeg = 0.0;
    notifyListeners();
  }

  FitEvaluationResult evaluateCurrentFit() {
    final room = activeRoom;
    final product = activeProduct;
    if (room == null || product == null) {
      return const FitEvaluationResult(
        status: FitStatus.fits,
        clearanceInches: 12.0,
        description: 'Ready to evaluate',
      );
    }
    return FitEngine.evaluate(
      room: room,
      product: product,
      posX: _placementX,
      posY: _placementY,
      rotationDeg: _rotationDeg,
    );
  }

  void addRoom(RoomModel room) {
    _rooms.add(room);
    _activeRoom = room;
    notifyListeners();
  }

  void updateRoom(RoomModel updated) {
    final idx = _rooms.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      _rooms[idx] = updated;
      if (_activeRoom?.id == updated.id) {
        _activeRoom = updated;
      }
      notifyListeners();
    }
  }

  void deleteRoom(String id) {
    _rooms.removeWhere((r) => r.id == id);
    if (_activeRoom?.id == id) {
      _activeRoom = _rooms.isNotEmpty ? _rooms.first : null;
    }
    notifyListeners();
  }

  void clearAllRooms() {
    _rooms.clear();
    _activeRoom = null;
    notifyListeners();
  }

  void saveFitCheck(FitCheckRecord record) {
    final existingIdx = _wishlist.indexWhere((item) => item.id == record.id);
    if (existingIdx != -1) {
      _wishlist[existingIdx] = record;
    } else {
      _wishlist.insert(0, record);
    }
    notifyListeners();
  }

  void deleteFitCheck(String id) {
    _wishlist.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void restoreFitCheck(FitCheckRecord record) {
    _activeProduct = record.product;
    final foundRoom = _rooms.firstWhere(
      (r) => r.id == record.roomId,
      orElse: () => _rooms.isNotEmpty ? _rooms.first : RoomModel(
        id: 'fallback',
        name: record.roomName,
        lengthFt: 14.0,
        widthFt: 12.0,
        scannedDate: DateTime.now(),
      ),
    );
    _activeRoom = foundRoom;
    _placementX = record.positionX;
    _placementY = record.positionY;
    _rotationDeg = record.rotationDeg;
    notifyListeners();
  }

  // Pre-populate 3 rooms and realistic wishlist items
  void _initSeedData() {
    final now = DateTime.now();

    final livingRoom = RoomModel(
      id: 'room_living',
      name: 'Living Room',
      lengthFt: 16.5,
      widthFt: 14.0,
      ceilingHeightFt: 9.0,
      scannedDate: now.subtract(const Duration(days: 4)),
      doorways: const [
        DoorwayMarker(id: 'd1', wallIndex: 2, normalizedOffset: 0.25, widthFt: 3.2), // South entry
        DoorwayMarker(id: 'd2', wallIndex: 1, normalizedOffset: 0.75, widthFt: 2.8), // East to balcony
      ],
      thumbnailSeed: 1,
    );

    final bedroom = RoomModel(
      id: 'room_bedroom',
      name: 'Primary Bedroom',
      lengthFt: 13.0,
      widthFt: 11.5,
      ceilingHeightFt: 8.5,
      scannedDate: now.subtract(const Duration(days: 7)),
      doorways: const [
        DoorwayMarker(id: 'd3', wallIndex: 3, normalizedOffset: 0.2, widthFt: 2.8), // West door
      ],
      thumbnailSeed: 2,
    );

    final study = RoomModel(
      id: 'room_study',
      name: 'Study / Home Office',
      lengthFt: 11.0,
      widthFt: 9.5,
      ceilingHeightFt: 8.5,
      scannedDate: now.subtract(const Duration(days: 12)),
      doorways: const [
        DoorwayMarker(id: 'd4', wallIndex: 0, normalizedOffset: 0.5, widthFt: 3.0), // North door
      ],
      thumbnailSeed: 3,
    );

    _rooms.addAll([livingRoom, bedroom, study]);
    _activeRoom = livingRoom;

    // Seed Wishlist
    final sofaProduct = ProductModel(
      id: 'prod_sofa_1',
      title: 'Kivik 3-Seat Sectional Sofa',
      source: ProductSource.online,
      category: ProductCategory.sofa,
      lengthIn: 90.0,
      widthIn: 38.0,
      heightIn: 33.0,
      confidence: ConfidenceLevel.directHigh,
      productUrl: 'https://ikea.com/item/kivik-3-seat-sofa',
      createdAt: now.subtract(const Duration(days: 2)),
    );

    final diningTable = ProductModel(
      id: 'prod_table_1',
      title: 'Oak Dining Table 6-Seater',
      source: ProductSource.offline,
      category: ProductCategory.table,
      lengthIn: 72.0,
      widthIn: 36.0,
      heightIn: 30.0,
      confidence: ConfidenceLevel.packagingAmber,
      barcode: '8901234567890',
      createdAt: now.subtract(const Duration(days: 3)),
    );

    final shelfProduct = ProductModel(
      id: 'prod_shelf_1',
      title: 'Industrial 5-Tier Bookshelf',
      source: ProductSource.online,
      category: ProductCategory.shelf,
      lengthIn: 48.0,
      widthIn: 16.0,
      heightIn: 70.0,
      confidence: ConfidenceLevel.directHigh,
      createdAt: now.subtract(const Duration(days: 5)),
    );

    final oversizeArmchair = ProductModel(
      id: 'prod_chair_1',
      title: 'Velvet King Lounge Chair',
      source: ProductSource.offline,
      category: ProductCategory.sofa,
      lengthIn: 52.0,
      widthIn: 46.0,
      heightIn: 38.0,
      confidence: ConfidenceLevel.directHigh,
      createdAt: now.subtract(const Duration(days: 1)),
    );

    _wishlist.addAll([
      FitCheckRecord(
        id: 'fit_1',
        product: sofaProduct,
        roomId: livingRoom.id,
        roomName: livingRoom.name,
        positionX: 0.1,
        positionY: 0.2,
        rotationDeg: 0,
        fitStatus: FitStatus.fits,
        clearanceInches: 18.5,
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      FitCheckRecord(
        id: 'fit_2',
        product: diningTable,
        roomId: livingRoom.id,
        roomName: livingRoom.name,
        positionX: -0.4,
        positionY: 0.35,
        rotationDeg: 90,
        fitStatus: FitStatus.tight,
        clearanceInches: 4.2,
        obstructionReason: 'Tight clearance (4.2" to balcony door)',
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      FitCheckRecord(
        id: 'fit_3',
        product: oversizeArmchair,
        roomId: study.id,
        roomName: study.name,
        positionX: 0.0,
        positionY: -0.7,
        rotationDeg: 0,
        fitStatus: FitStatus.wontFit,
        clearanceInches: 0.0,
        obstructionReason: 'Blocks doorway',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      FitCheckRecord(
        id: 'fit_4',
        product: shelfProduct,
        roomId: bedroom.id,
        roomName: bedroom.name,
        positionX: 0.65,
        positionY: -0.1,
        rotationDeg: 90,
        fitStatus: FitStatus.fits,
        clearanceInches: 22.0,
        timestamp: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }
}
