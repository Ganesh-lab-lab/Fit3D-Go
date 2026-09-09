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
}
