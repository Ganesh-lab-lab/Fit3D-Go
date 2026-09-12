import 'package:flutter/material.dart';
import '../models/fit_check_record.dart';
import '../models/product_model.dart';
import '../models/room_model.dart';
import '../services/supabase_service.dart';
import 'fit_engine.dart';

class RoomFitState extends ChangeNotifier {
  final List<RoomModel> _rooms = [];
  final List<FitCheckRecord> _wishlist = [];

  RoomModel? _activeRoom;
  ProductModel? _activeProduct;

  bool _isLoading = false;

  // Real-time placement state
  double _placementX = 0.0;
  double _placementY = 0.0;
  double _rotationDeg = 0.0;

  RoomFitState() {
    // Initial state starts empty; data will be hydrated from Supabase when user logs in
  }

  List<RoomModel> get rooms => List.unmodifiable(_rooms);
  List<FitCheckRecord> get wishlist => List.unmodifiable(_wishlist);
  RoomModel? get activeRoom =>
      _activeRoom ?? (_rooms.isNotEmpty ? _rooms.first : null);
  ProductModel? get activeProduct => _activeProduct;
  bool get isLoading => _isLoading;

  double get placementX => _placementX;
  double get placementY => _placementY;
  double get rotationDeg => _rotationDeg;

  /// Hydrate rooms and wishlist items from Supabase for the authenticated user
  Future<void> loadFromSupabase() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedRooms = await SupabaseService.instance.fetchRooms();
      final fetchedChecks = await SupabaseService.instance.fetchFitChecks();

      _rooms.clear();
      _rooms.addAll(fetchedRooms);

      _wishlist.clear();
      _wishlist.addAll(fetchedChecks);

      if (_rooms.isNotEmpty) {
        if (_activeRoom == null || !_rooms.any((r) => r.id == _activeRoom?.id)) {
          _activeRoom = _rooms.first;
        }
      } else {
        _activeRoom = null;
      }
    } catch (e, stack) {
      debugPrint('⚠️ RoomFitState.loadFromSupabase error: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears in-memory state on sign-out
  void clearLocalState() {
    _rooms.clear();
    _wishlist.clear();
    _activeRoom = null;
    _activeProduct = null;
    resetPlacement();
    notifyListeners();
  }

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

    // Persist asynchronously to Supabase
    SupabaseService.instance.insertRoom(room).catchError((e) {
      debugPrint('⚠️ Error inserting room to Supabase: $e');
    });
  }

  void updateRoom(RoomModel updated) {
    final idx = _rooms.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      _rooms[idx] = updated;
      if (_activeRoom?.id == updated.id) {
        _activeRoom = updated;
      }
      notifyListeners();

      // Persist update to Supabase
      SupabaseService.instance.insertRoom(updated).catchError((e) {
        debugPrint('⚠️ Error updating room in Supabase: $e');
      });
    }
  }

  void deleteRoom(String id) {
    _rooms.removeWhere((r) => r.id == id);
    if (_activeRoom?.id == id) {
      _activeRoom = _rooms.isNotEmpty ? _rooms.first : null;
    }
    notifyListeners();

    // Delete from Supabase
    SupabaseService.instance.deleteRoom(id).catchError((e) {
      debugPrint('⚠️ Error deleting room from Supabase: $e');
    });
  }

  void clearAllRooms() {
    _rooms.clear();
    _activeRoom = null;
    notifyListeners();

    // Clear from Supabase
    SupabaseService.instance.clearAllRooms().catchError((e) {
      debugPrint('⚠️ Error clearing rooms from Supabase: $e');
    });
  }

  void saveFitCheck(FitCheckRecord record) {
    final existingIdx = _wishlist.indexWhere((item) => item.id == record.id);
    if (existingIdx != -1) {
      _wishlist[existingIdx] = record;
    } else {
      _wishlist.insert(0, record);
    }
    notifyListeners();

    // Persist to Supabase
    SupabaseService.instance.insertFitCheck(record).catchError((e) {
      debugPrint('⚠️ Error saving fit check to Supabase: $e');
    });
  }

  void deleteFitCheck(String id) {
    _wishlist.removeWhere((item) => item.id == id);
    notifyListeners();

    // Delete from Supabase
    SupabaseService.instance.deleteFitCheck(id).catchError((e) {
      debugPrint('⚠️ Error deleting fit check from Supabase: $e');
    });
  }

  void restoreFitCheck(FitCheckRecord record) {
    _activeProduct = record.product;
    final foundRoom = _rooms.firstWhere(
      (r) => r.id == record.roomId,
      orElse: () => _rooms.isNotEmpty
          ? _rooms.first
          : RoomModel(
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
}
