import 'dart:math' as math;

/// Represents a doorway position on a wall
class DoorwayMarker {
  final String id;
  /// Wall index: 0 = North (top), 1 = East (right), 2 = South (bottom), 3 = West (left)
  final int wallIndex;
  /// Position along wall normalized [0.0, 1.0]
  final double normalizedOffset;
  /// Width of doorway in feet (e.g. 3.0 ft)
  final double widthFt;

  const DoorwayMarker({
    required this.id,
    required this.wallIndex,
    required this.normalizedOffset,
    this.widthFt = 3.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'wallIndex': wallIndex,
        'normalizedOffset': normalizedOffset,
        'widthFt': widthFt,
      };

  factory DoorwayMarker.fromJson(Map<String, dynamic> json) => DoorwayMarker(
        id: json['id'] as String,
        wallIndex: json['wallIndex'] as int,
        normalizedOffset: (json['normalizedOffset'] as num).toDouble(),
        widthFt: (json['widthFt'] as num?)?.toDouble() ?? 3.0,
      );
}

/// Represents a scanned Room with 3D boundaries, dimensions, and doorways
class RoomModel {
  final String id;
  final String name;
  final double lengthFt; // In feet
  final double widthFt;  // In feet
  final double ceilingHeightFt; // In feet
  final DateTime scannedDate;
  final List<DoorwayMarker> doorways;
  final int thumbnailSeed;

  const RoomModel({
    required this.id,
    required this.name,
    required this.lengthFt,
    required this.widthFt,
    this.ceilingHeightFt = 9.0,
    required this.scannedDate,
    this.doorways = const [],
    this.thumbnailSeed = 1,
  });

  String get dimensionsDisplay =>
      '${lengthFt.toStringAsFixed(1)}ft x ${widthFt.toStringAsFixed(1)}ft, ${ceilingHeightFt.toStringAsFixed(0)}ft ceiling';

  String get shortDimensions =>
      "${lengthFt.toStringAsFixed(0)}' x ${widthFt.toStringAsFixed(0)}'";

  double get areaSqFt => lengthFt * widthFt;

  RoomModel copyWith({
    String? id,
    String? name,
    double? lengthFt,
    double? widthFt,
    double? ceilingHeightFt,
    DateTime? scannedDate,
    List<DoorwayMarker>? doorways,
    int? thumbnailSeed,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lengthFt: lengthFt ?? this.lengthFt,
      widthFt: widthFt ?? this.widthFt,
      ceilingHeightFt: ceilingHeightFt ?? this.ceilingHeightFt,
      scannedDate: scannedDate ?? this.scannedDate,
      doorways: doorways ?? this.doorways,
      thumbnailSeed: thumbnailSeed ?? this.thumbnailSeed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'length_ft': lengthFt,
        'width_ft': widthFt,
        'ceiling_height_ft': ceilingHeightFt,
        'scanned_date': scannedDate.toIso8601String(),
        'doorways': doorways.map((d) => d.toJson()).toList(),
        'thumbnail_seed': thumbnailSeed,
      };

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    List<DoorwayMarker> parsedDoorways = [];
    if (json['doorways'] is List) {
      parsedDoorways = (json['doorways'] as List)
          .map((d) => DoorwayMarker.fromJson(Map<String, dynamic>.from(d as Map)))
          .toList();
    }

    double length = 14.0;
    double width = 12.0;
    double ceiling = 9.0;

    if (json['length_ft'] != null) {
      length = (json['length_ft'] as num).toDouble();
    } else if (json['dimensions'] is Map) {
      final dim = json['dimensions'] as Map;
      length = (dim['length_ft'] as num?)?.toDouble() ??
               (dim['length'] as num?)?.toDouble() ?? 14.0;
    }

    if (json['width_ft'] != null) {
      width = (json['width_ft'] as num).toDouble();
    } else if (json['dimensions'] is Map) {
      final dim = json['dimensions'] as Map;
      width = (dim['width_ft'] as num?)?.toDouble() ??
              (dim['width'] as num?)?.toDouble() ?? 12.0;
    }

    if (json['ceiling_height_ft'] != null) {
      ceiling = (json['ceiling_height_ft'] as num).toDouble();
    } else if (json['dimensions'] is Map) {
      final dim = json['dimensions'] as Map;
      ceiling = (dim['ceiling_height_ft'] as num?)?.toDouble() ??
                (dim['ceiling_height'] as num?)?.toDouble() ??
                (dim['height_ft'] as num?)?.toDouble() ?? 9.0;
    }

    return RoomModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Room',
      lengthFt: length,
      widthFt: width,
      ceilingHeightFt: ceiling,
      scannedDate: json['scanned_date'] != null
          ? DateTime.parse(json['scanned_date'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
      doorways: parsedDoorways,
      thumbnailSeed: (json['thumbnail_seed'] as num?)?.toInt() ?? 1,
    );
  }
}
