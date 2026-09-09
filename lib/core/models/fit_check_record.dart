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
}
