import 'product_model.dart';

enum FitStatus {
  fits(
    label: 'Fits comfortably',
    shortLabel: 'Fits',
    statusColorHex: 0xFF00E676,
    bgColorHex: 0x2400E676,
  ),
  tight(
    label: 'Tight fit',
    shortLabel: 'Tight',
    statusColorHex: 0xFFFFB300,
    bgColorHex: 0x24FFB300,
  ),
  wontFit(
    label: "Won't fit here",
    shortLabel: "Won't Fit",
    statusColorHex: 0xFFFF3B30,
    bgColorHex: 0x24FF3B30,
  );

  final String label;
  final String shortLabel;
  final int statusColorHex;
  final int bgColorHex;
  const FitStatus({
    required this.label,
    required this.shortLabel,
    required this.statusColorHex,
    required this.bgColorHex,
  });
}

class FitCheckRecord {
  final String id;
  final ProductModel product;
  final String roomId;
  final String roomName;
  final double positionX; // Offset in room units [-1.0, 1.0]
  final double positionY; // Offset in room units [-1.0, 1.0]
  final double rotationDeg; // Rotation in degrees [0, 360)
  final FitStatus fitStatus;
  final double clearanceInches;
  final String? obstructionReason;
  final DateTime timestamp;

  const FitCheckRecord({
    required this.id,
    required this.product,
    required this.roomId,
    required this.roomName,
    this.positionX = 0.0,
    this.positionY = 0.0,
    this.rotationDeg = 0.0,
    required this.fitStatus,
    required this.clearanceInches,
    this.obstructionReason,
    required this.timestamp,
  });

  FitCheckRecord copyWith({
    String? id,
    ProductModel? product,
    String? roomId,
    String? roomName,
    double? positionX,
    double? positionY,
    double? rotationDeg,
    FitStatus? fitStatus,
    double? clearanceInches,
    String? obstructionReason,
    DateTime? timestamp,
  }) {
    return FitCheckRecord(
      id: id ?? this.id,
      product: product ?? this.product,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      rotationDeg: rotationDeg ?? this.rotationDeg,
      fitStatus: fitStatus ?? this.fitStatus,
      clearanceInches: clearanceInches ?? this.clearanceInches,
      obstructionReason: obstructionReason ?? this.obstructionReason,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': product.id,
        'product_data': product.toJson(),
        'room_id': roomId,
        'room_name': roomName,
        'position_x': positionX,
        'position_y': positionY,
        'rotation_deg': rotationDeg,
        'fit_status': fitStatus.name,
        'clearance_inches': clearanceInches,
        'obstruction_reason': obstructionReason,
        'timestamp': timestamp.toIso8601String(),
      };

  factory FitCheckRecord.fromJson(Map<String, dynamic> json) {
    ProductModel product;
    if (json['product_data'] != null && json['product_data'] is Map) {
      product = ProductModel.fromJson(
        Map<String, dynamic>.from(json['product_data'] as Map),
      );
    } else {
      // Fallback product if product_data was not saved
      product = ProductModel(
        id: json['product_id'] as String? ?? 'prod_unknown',
        title: json['product_title'] as String? ?? 'Item',
        source: ProductSource.offline,
        category: ProductCategory.other,
        lengthIn: 36.0,
        widthIn: 24.0,
        heightIn: 30.0,
        confidence: ConfidenceLevel.directHigh,
        createdAt: DateTime.now(),
      );
    }

    return FitCheckRecord(
      id: json['id'] as String,
      product: product,
      roomId: json['room_id'] as String,
      roomName: json['room_name'] as String,
      positionX: (json['position_x'] as num?)?.toDouble() ?? 0.0,
      positionY: (json['position_y'] as num?)?.toDouble() ?? 0.0,
      rotationDeg: (json['rotation_deg'] as num?)?.toDouble() ?? 0.0,
      fitStatus: FitStatus.values.firstWhere(
        (e) => e.name == json['fit_status'],
        orElse: () => FitStatus.fits,
      ),
      clearanceInches: (json['clearance_inches'] as num?)?.toDouble() ?? 0.0,
      obstructionReason: json['obstruction_reason'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
