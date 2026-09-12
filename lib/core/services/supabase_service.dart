import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton wrapper around the Supabase client, exposing typed auth
/// and CRUD helpers for the rooms, products, and fit_checks tables.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  /// The currently authenticated user, or `null` if signed out.
  User? get currentUser => _client.auth.currentUser;

  /// Create a new account with email + password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return _client.auth.signUp(email: email, password: password);
  }

  /// Sign in with email + password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // Rooms
  // ---------------------------------------------------------------------------

  /// Insert a room row. Returns the inserted row as a map.
  Future<Map<String, dynamic>> insertRoom({
    required String id,
    required String name,
    required double lengthFt,
    required double widthFt,
    double ceilingHeightFt = 9.0,
    required DateTime scannedDate,
    List<Map<String, dynamic>> doorways = const [],
    int thumbnailSeed = 1,
  }) async {
    final row = {
      'id': id,
      'name': name,
      'length_ft': lengthFt,
      'width_ft': widthFt,
      'ceiling_height_ft': ceilingHeightFt,
      'scanned_date': scannedDate.toIso8601String(),
      'doorways': doorways,
      'thumbnail_seed': thumbnailSeed,
    };
    final userId = currentUser?.id;
    if (userId != null) row['user_id'] = userId;

    final res = await _client.from('rooms').insert(row).select().single();
    return res;
  }

  /// Fetch all rooms (optionally filtered by current user).
  Future<List<Map<String, dynamic>>> fetchRooms() async {
    final query = _client.from('rooms').select();
    final userId = currentUser?.id;
    if (userId != null) {
      return await query.eq('user_id', userId);
    }
    return await query;
  }

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  /// Insert a product row. Returns the inserted row as a map.
  Future<Map<String, dynamic>> insertProduct({
    required String id,
    required String title,
    required String source,
    required String category,
    required double lengthIn,
    required double widthIn,
    required double heightIn,
    required String confidence,
    String? imageUrl,
    String? barcode,
    String? productUrl,
    required DateTime createdAt,
  }) async {
    final row = <String, dynamic>{
      'id': id,
      'title': title,
      'source': source,
      'category': category,
      'length_in': lengthIn,
      'width_in': widthIn,
      'height_in': heightIn,
      'confidence': confidence,
      'image_url': imageUrl,
      'barcode': barcode,
      'product_url': productUrl,
      'created_at': createdAt.toIso8601String(),
    };
    final userId = currentUser?.id;
    if (userId != null) row['user_id'] = userId;

    final res = await _client.from('products').insert(row).select().single();
    return res;
  }

  /// Fetch all products (optionally filtered by current user).
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final query = _client.from('products').select();
    final userId = currentUser?.id;
    if (userId != null) {
      return await query.eq('user_id', userId);
    }
    return await query;
  }

  // ---------------------------------------------------------------------------
  // Fit Checks
  // ---------------------------------------------------------------------------

  /// Insert a fit-check row. Returns the inserted row as a map.
  Future<Map<String, dynamic>> insertFitCheck({
    required String id,
    required String productId,
    required String roomId,
    required String roomName,
    double positionX = 0.0,
    double positionY = 0.0,
    double rotationDeg = 0.0,
    required String fitStatus,
    required double clearanceInches,
    String? obstructionReason,
    required DateTime timestamp,
  }) async {
    final row = <String, dynamic>{
      'id': id,
      'product_id': productId,
      'room_id': roomId,
      'room_name': roomName,
      'position_x': positionX,
      'position_y': positionY,
      'rotation_deg': rotationDeg,
      'fit_status': fitStatus,
      'clearance_inches': clearanceInches,
      'obstruction_reason': obstructionReason,
      'timestamp': timestamp.toIso8601String(),
    };
    final userId = currentUser?.id;
    if (userId != null) row['user_id'] = userId;

    final res =
        await _client.from('fit_checks').insert(row).select().single();
    return res;
  }

  /// Fetch fit checks, optionally filtered by [roomId].
  Future<List<Map<String, dynamic>>> fetchFitChecks({String? roomId}) async {
    var query = _client.from('fit_checks').select();
    final userId = currentUser?.id;
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    if (roomId != null) {
      return await query.eq('room_id', roomId);
    }
    return await query;
  }
}
