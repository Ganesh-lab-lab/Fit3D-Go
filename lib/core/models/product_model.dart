enum ProductSource {
  online,
  offline,
}

enum ProductCategory {
  sofa('Sofa', '🛋️'),
  table('Table', '🪑'),
  lamp('Lamp', '💡'),
  shelf('Shelf', '📚'),
  other('Other', '📦');

  final String label;
  final String emoji;
  const ProductCategory(this.label, this.emoji);
}

enum ConfidenceLevel {
  directHigh(
    label: 'Measured directly — high confidence',
    shortLabel: 'High Confidence',
    badgeColorHex: 0xFF00E676,
  ),
  packagingAmber(
    label: 'May be packaging size — confirm with camera scan?',
    shortLabel: 'Unverified Barcode',
    badgeColorHex: 0xFFFFB300,
  ),
  unverifiedRed(
    label: 'No dimensions found for this barcode',
    shortLabel: 'Not Found',
    badgeColorHex: 0xFFFF3B30,
  );

  final String label;
  final String shortLabel;
  final int badgeColorHex;
  const ConfidenceLevel({
    required this.label,
    required this.shortLabel,
    required this.badgeColorHex,
  });
}

class ProductModel {
  final String id;
  final String title;
  final ProductSource source;
  final ProductCategory category;
  final double lengthIn; // Inches
  final double widthIn;  // Inches
  final double heightIn; // Inches
  final ConfidenceLevel confidence;
  final String? imageUrl;
  final String? barcode;
  final String? productUrl;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.title,
    required this.source,
    required this.category,
    required this.lengthIn,
    required this.widthIn,
    required this.heightIn,
    required this.confidence,
    this.imageUrl,
    this.barcode,
    this.productUrl,
    required this.createdAt,
  });

  String get dimensionsDisplay =>
      '${lengthIn.toStringAsFixed(0)}"L x ${widthIn.toStringAsFixed(0)}"W x ${heightIn.toStringAsFixed(0)}"H';

  String get dimensionsFeetDisplay {
    final lFt = (lengthIn / 12).toStringAsFixed(1);
    final wFt = (widthIn / 12).toStringAsFixed(1);
    final hFt = (heightIn / 12).toStringAsFixed(1);
    return '${lFt}ft x ${wFt}ft x ${hFt}ft';
  }

  ProductModel copyWith({
    String? id,
    String? title,
    ProductSource? source,
    ProductCategory? category,
    double? lengthIn,
    double? widthIn,
    double? heightIn,
    ConfidenceLevel? confidence,
    String? imageUrl,
    String? barcode,
    String? productUrl,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      source: source ?? this.source,
      category: category ?? this.category,
      lengthIn: lengthIn ?? this.lengthIn,
      widthIn: widthIn ?? this.widthIn,
      heightIn: heightIn ?? this.heightIn,
      confidence: confidence ?? this.confidence,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      productUrl: productUrl ?? this.productUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'source': source.name,
        'category': category.name,
        'length_in': lengthIn,
        'width_in': widthIn,
        'height_in': heightIn,
        'confidence': confidence.name,
        'image_url': imageUrl,
        'barcode': barcode,
        'product_url': productUrl,
        'created_at': createdAt.toIso8601String(),
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double l = 36.0;
    double w = 24.0;
    double h = 30.0;

    if (json['length_in'] != null) {
      l = (json['length_in'] as num).toDouble();
    } else if (json['dimensions'] is Map) {
      final dim = json['dimensions'] as Map;
      l = (dim['length_in'] as num?)?.toDouble() ?? (dim['length'] as num?)?.toDouble() ?? 36.0;
    }

    if (json['width_in'] != null) {
      w = (json['width_in'] as num).toDouble();
    } else if (json['dimensions'] is Map) {
      final dim = json['dimensions'] as Map;
      w = (dim['width_in'] as num?)?.toDouble() ?? (dim['width'] as num?)?.toDouble() ?? 24.0;
    }

    if (json['height_in'] != null) {
      h = (json['height_in'] as num).toDouble();
    } else if (json['dimensions'] is Map) {
      final dim = json['dimensions'] as Map;
      h = (dim['height_in'] as num?)?.toDouble() ?? (dim['height'] as num?)?.toDouble() ?? 30.0;
    }

    return ProductModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? json['name'] as String? ?? 'Product',
      source: ProductSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => ProductSource.offline,
      ),
      category: ProductCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ProductCategory.other,
      ),
      lengthIn: l,
      widthIn: w,
      heightIn: h,
      confidence: ConfidenceLevel.values.firstWhere(
        (e) => e.name == json['confidence'],
        orElse: () => ConfidenceLevel.directHigh,
      ),
      imageUrl: json['image_url'] as String?,
      barcode: json['barcode'] as String?,
      productUrl: json['product_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
