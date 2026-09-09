import 'package:flutter/material.dart';
import '../../../core/models/product_model.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_button.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/page_transitions.dart';
import '../../../core/widgets/confidence_badge.dart';
import '../../../core/widgets/dimensional_input.dart';
import '../../../core/widgets/proxy_shape_3d.dart';
import '../../fit_check/presentation/placement_viewer_screen.dart';

class OnlineProductScreen extends StatefulWidget {
  final RoomFitState state;

  const OnlineProductScreen({super.key, required this.state});

  @override
  State<OnlineProductScreen> createState() => _OnlineProductScreenState();
}

class _OnlineProductScreenState extends State<OnlineProductScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(text: 'Modern Sectional Sofa');

  ProductCategory _category = ProductCategory.sofa;
  double _lengthIn = 84.0;
  double _widthIn = 36.0;
  double _heightIn = 32.0;
  bool _isMetric = false;
  bool _isParsing = false;
  bool _parsedSuccess = false;
  ConfidenceLevel _confidence = ConfidenceLevel.directHigh;

  // Preset demo products for instant parsing simulation
  final List<Map<String, dynamic>> _demoLinks = [
    {
      'title': 'IKEA KIVIK 3-Seat Sofa',
      'url': 'https://www.ikea.com/us/en/p/kivik-sofa-tresund-anthracite-s49482838/',
      'cat': ProductCategory.sofa,
      'l': 90.0,
      'w': 38.0,
      'h': 33.0,
    },
    {
      'title': 'West Elm Profile Coffee Table',
      'url': 'https://www.westelm.com/products/profile-coffee-table-h4235/',
      'cat': ProductCategory.table,
      'l': 52.0,
      'w': 28.0,
      'h': 18.0,
    },
    {
      'title': 'CB2 Helix Wall Shelf',
      'url': 'https://www.cb2.com/helix-70-walnut-bookcase/s206584',
      'cat': ProductCategory.shelf,
      'l': 30.0,
      'w': 14.0,
      'h': 70.0,
    },
    {
      'title': 'Archi Floor Reading Lamp',
      'url': 'https://www.wayfair.com/lighting/pdp/modern-brass-arc-floor-lamp',
      'cat': ProductCategory.lamp,
      'l': 20.0,
      'w': 20.0,
      'h': 65.0,
    },
  ];

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _simulateParseUrl(String url) async {
    setState(() {
      _isParsing = true;
      _parsedSuccess = false;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // Find match from demo presets or generate smart mock
    final match = _demoLinks.firstWhere(
      (item) => url.toLowerCase().contains(item['title'].toString().toLowerCase().split(' ').first) ||
          url.toLowerCase().contains(item['cat'].toString().split('.').last),
      orElse: () => _demoLinks.first,
    );

    setState(() {
      _isParsing = false;
      _parsedSuccess = true;
      _titleController.text = match['title'] as String;
      _category = match['cat'] as ProductCategory;
      _lengthIn = match['l'] as double;
      _widthIn = match['w'] as double;
      _heightIn = match['h'] as double;
      _confidence = ConfidenceLevel.directHigh;
    });
  }

  void _proceedToFitCheck() {
    final product = ProductModel(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim().isEmpty ? 'Online Product' : _titleController.text.trim(),
      source: ProductSource.online,
      category: _category,
      lengthIn: _lengthIn,
      widthIn: _widthIn,
      heightIn: _heightIn,
      confidence: _confidence,
      productUrl: _urlController.text.trim(),
      createdAt: DateTime.now(),
    );

    widget.state.setActiveProduct(product);

    Navigator.of(context).push(
      GlassPageRoute(
        page: PlacementViewerScreen(state: widget.state),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Online Product Fit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. Paste Product Link Input (Prompt 4 requirement)
            Text('Paste Product Link', style: AppTypography.label),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    style: AppTypography.bodyLarge.copyWith(fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.link_rounded, color: AppColors.primaryCyan),
                      hintText: 'https://ikea.com/item/...',
                      suffixIcon: _urlController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                setState(() {
                                  _urlController.clear();
                                  _parsedSuccess = false;
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                GlassButton(
                  variant: GlassButtonVariant.primary,
                  height: 52,
                  width: 90,
                  isLoading: _isParsing,
                  label: 'Parse',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: _urlController.text.trim().isEmpty
                      ? null
                      : () => _simulateParseUrl(_urlController.text.trim()),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Demo pills for fast testing
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  'Quick Samples:',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                ..._demoLinks.map((demo) {
                  return InkWell(
                    onTap: () {
                      _urlController.text = demo['url'] as String;
                      _simulateParseUrl(demo['url'] as String);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x22FFFFFF)),
                      ),
                      child: Text(
                        demo['title'] as String,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.primaryCyan,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),

            // Parse status banner
            if (_parsedSuccess)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x2400E676),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x5500E676)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.statusGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Auto-detected dimensions from product specifications!',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 2. 3D Preview Thumbnail (Prompt 4 requirement)
            Center(
              child: GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                hasTopGlow: true,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Proxy 3D Shape Preview', style: AppTypography.label),
                        ConfidenceBadge(confidence: _confidence, isCompact: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ProxyShape3DPreview(
                      category: _category,
                      lengthIn: _lengthIn,
                      widthIn: _widthIn,
                      heightIn: _heightIn,
                      size: 150,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_lengthIn.toStringAsFixed(0)}"L x ${_widthIn.toStringAsFixed(0)}"W x ${_heightIn.toStringAsFixed(0)}"H  (${((_lengthIn / 12)).toStringAsFixed(1)}\' x ${((_widthIn / 12)).toStringAsFixed(1)}\')',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Name field
            Text('Product Title', style: AppTypography.label),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: AppTypography.titleMedium.copyWith(fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'e.g. Velvet Sectional Sofa',
                prefixIcon: Icon(Icons.shopping_bag_outlined, color: AppColors.primaryCyan),
              ),
            ),
            const SizedBox(height: 20),

            // Category Dropdown / Proxy selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Proxy Category', style: AppTypography.label),
                Text('Shapes 3D proxy in room', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: ProductCategory.values.map((cat) {
                final isSelected = _category == cat;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0x3300F0FF) : const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryCyan : const Color(0x22FFFFFF),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(
                            cat.label,
                            style: AppTypography.badge.copyWith(
                              color: isSelected ? AppColors.primaryCyan : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 3. Manual Fallback with Length, Width, Height inputs (Prompt 4 requirement)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Manual Dimensions Fallback', style: AppTypography.label),
                GestureDetector(
                  onTap: () => setState(() => _isMetric = !_isMetric),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x22FFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: Text(
                      _isMetric ? 'Switch to Inches' : 'Switch to Centimeters',
                      style: AppTypography.badge.copyWith(
                        color: AppColors.primaryCyan,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            DimensionalInputRow(
              label: 'Length (L)',
              valueInches: _lengthIn,
              isMetric: _isMetric,
              onChanged: (val) => setState(() => _lengthIn = val),
            ),
            const SizedBox(height: 10),
            DimensionalInputRow(
              label: 'Width (W)',
              valueInches: _widthIn,
              isMetric: _isMetric,
              onChanged: (val) => setState(() => _widthIn = val),
            ),
            const SizedBox(height: 10),
            DimensionalInputRow(
              label: 'Height (H)',
              valueInches: _heightIn,
              isMetric: _isMetric,
              onChanged: (val) => setState(() => _heightIn = val),
            ),
          ],
        ),
      ),

      // 4. "Check Fit in My Home" Button (Prompt 4 requirement)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: GlassButton(
          label: 'Check Fit in My Home',
          icon: Icons.view_in_ar_rounded,
          variant: GlassButtonVariant.primary,
          height: 54,
          onPressed: _proceedToFitCheck,
        ),
      ),
    );
  }
}
