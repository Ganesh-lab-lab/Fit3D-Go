import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fit_check_record.dart';
import '../models/product_model.dart';
import '../models/room_model.dart';
import '../utils/uuid_util.dart';

/// Singleton wrapper around the Supabase client, exposing typed auth
/// and CRUD helpers for rooms, products, and fit-checks.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  /// The currently authenticated user, or `null` if signed out.
  User? get currentUser => client.auth.currentUser;

  /// Whether a user is currently logged in.
  bool get isAuthenticated => currentUser != null;

  /// Auth state change stream.
  Stream<AuthState> get onAuthStateChange => client.auth.onAuthStateChange;

  /// Create a new account with email + password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return client.auth.signUp(email: email, password: password);
  }

  /// Sign in with email + password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // Rooms
  // ---------------------------------------------------------------------------

  /// Upsert a room row into Supabase. Compatible with both JSONB dimensions and flat columns.
  Future<void> insertRoom(RoomModel room) async {
    try {
      final validId = UuidUtil.ensureValidUuid(room.id);
      final userId = currentUser?.id;

      final row = <String, dynamic>{
        'id': validId,
        'name': room.name,
        'dimensions': {
          'length_ft': room.lengthFt,
          'width_ft': room.widthFt,
          'ceiling_height_ft': room.ceilingHeightFt,
        },
        'doorways': room.doorways.map((d) => d.toJson()).toList(),
      };
      if (userId != null) {
        row['user_id'] = userId;
      }

      try {
        await client.from('rooms').upsert(row);
      } catch (e) {
        // Fallback: try with flat columns in case schema migration has flat structure
        final flatRow = Map<String, dynamic>.from(row);
        flatRow['length_ft'] = room.lengthFt;
        flatRow['width_ft'] = room.widthFt;
        flatRow['ceiling_height_ft'] = room.ceilingHeightFt;
        flatRow['thumbnail_seed'] = room.thumbnailSeed;
        flatRow['scanned_date'] = room.scannedDate.toIso8601String();
        await client.from('rooms').upsert(flatRow);
      }
    } catch (e, stack) {
      debugPrint('⚠️ SupabaseService.insertRoom error: $e\n$stack');
      rethrow;
    }
  }

  /// Fetch all rooms for the current user.
  Future<List<RoomModel>> fetchRooms() async {
    try {
      final userId = currentUser?.id;
      var query = client.from('rooms').select();
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      final res = await query.order('created_at', ascending: false);
      return (res as List)
          .map((e) => RoomModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e, stack) {
      debugPrint('⚠️ SupabaseService.fetchRooms error: $e\n$stack');
      return [];
    }
  }

  /// Delete a room by ID.
  Future<void> deleteRoom(String id) async {
    try {
      final validId = UuidUtil.isValidUuid(id) ? id : null;
      if (validId != null) {
        await client.from('rooms').delete().eq('id', validId);
      } else {
        await client.from('rooms').delete().eq('id', id);
      }
    } catch (e, stack) {
      debugPrint('⚠️ SupabaseService.deleteRoom error: $e\n$stack');
      rethrow;
    }
  }

  /// Delete all rooms for the current user.
  Future<void> clearAllRooms() async {
    try {
      final userId = currentUser?.id;
      if (userId != null) {
        await client.from('rooms').delete().eq('user_id', userId);
      }
    } catch (e, stack) {
      debugPrint('⚠️ SupabaseService.clearAllRooms error: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  /// Upsert a product row into Supabase.
  Future<void> insertProduct(ProductModel product) async {
    try {
      final validId = UuidUtil.ensureValidUuid(product.id);
      final userId = currentUser?.id;

      final row = <String, dynamic>{
        'id': validId,
        'name': product.title,
        'source': product.source.name,
        'confidence': product.confidence.name,
        'dimensions': {
          'length_in': product.lengthIn,
          'width_in': product.widthIn,
          'height_in': product.heightIn,
        },
      };
      if (userId != null) {
        row['user_id'] = userId;
      }

      try {
        await client.from('products').upsert(row);
      } catch (e) {
        // Fallback: try with flat columns
        final flatRow = Map<String, dynamic>.from(row);
        flatRow['title'] = product.title;
        flatRow['category'] = product.category.name;
        flatRow['length_in'] = product.lengthIn;
        flatRow['width_in'] = product.widthIn;
        flatRow['height_in'] = product.heightIn;
        flatRow['image_url'] = product.imageUrl;
        flatRow['barcode'] = product.barcode;
        flatRow['product_url'] = product.productUrl;
        await client.from('products').upsert(flatRow);
      }
    } catch (e, stack) {
      debugPrint('⚠️ SupabaseService.insertProduct error: $e\n$stack');
      rethrow;
    }
  }

  /// Fetch all products for the current user.
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final userId = currentUser?.id;
      var query = client.from('products').select();
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      final res = await query.order('created_at', ascending: false);
      return (res as List)
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e, stack) {
      debugPrint('⚠️ SupabaseService.fetchProducts error: $e\n$stack');
      return [];
    }
  }

  /// Delete a product by ID.
  Future<void> deleteProduct(String id) async {
    try {
      await client.from('products').delete().eq('id', id);
    } catch (e, stack) {
      debugPrint('⚠️ SupabaseService.deleteProduct error: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Fit Checks / Wishlist
  // ---------------------------------------------------------------------------

  /// Upsert a fit-check record into Supabase. Also persists the embedded product.
  Future<void> insertFitCheck(FitCheckRecord record) async {
    try {
      final validRecordId = UuidUtil.ensureValidUuid(record.id);
      final validProductId = UuidUtil.ensureValidUuid(record.product.id);
      final validRoomId = UuidUtil.ensureValidUuid(record.roomId);
      final userId = currentUser?.id;

      // Upsert product with matching UUID
      await insertProduct(record.product.copyWith(id: validProductId));

      final row = <String, dynamic>{
        'id': validRecordId,
        'product_id': validProductId,
        'room_id': validRoomId,
        'fit_status': record.fitStatus.name,
      };
      if (userId != null) {
        row['user_id'] = userId;
      }

      try {
        await client.from('fit_checks').upsert(row);
      } catch (e) {
        // Fallback: try with full metadata columns
        final fullRow = Map<String, dynamic>.from(row);
        fullRow['product_data'] = record.product.toJson();
        fullRow['room_name'] = record.roomName;
        fullRow['position_x'] = record.positionX;
        fullRow['position_y'] = record.positionY;
        fullRow['rotation_deg'] = record.rotationDeg;
        fullRow['clearance_inches'] = record.clearanceInches;
        fullRow['obstruction_reason'] = record.obstructionReason;
        fullRow['timestamp'] = record.timestamp.toIso8601String();
        await client.from('fit_checks').upsert(fullRow);
      }
    } catch (e, stack) {
      debugPrint('⚠️ SupabaseService.insertFitCheck error: $e\n$stack');
      rethrow;
    }
  }

  /// Fetch fit checks (wishlist), optionally filtered by [roomId].
  Future<List<FitCheckRecord>> fetchFitChecks({String? roomId}) async {
    try {
      final userId = currentUser?.id;
      var query = client.from('fit_checks').select();
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      if (roomId != null) {
        final validRoomId = UuidUtil.isValidUuid(roomId) ? roomId : null;
        if (validRoomId != null) {
          query = query.eq('room_id', validRoomId);
        }
      }
      final res = await query.order('created_at', ascending: false);
      return (res as List)
          .map((e) => FitCheckRecord.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e, stack) {
      debugPrint('⚠️ SupabaseService.fetchFitChecks error: $e\n$stack');
      return [];
    }
  }

  /// Delete a fit-check record by ID.
  Future<void> deleteFitCheck(String id) async {
    try {
      await client.from('fit_checks').delete().eq('id', id);
    } catch (e, stack) {
      debugPrint('⚠️ SupabaseService.deleteFitCheck error: $e\n$stack');
      rethrow;
    }
  }
}
