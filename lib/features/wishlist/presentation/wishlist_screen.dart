import 'package:flutter/material.dart';
import '../../../core/models/fit_check_record.dart';
import '../../../core/models/product_model.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/page_transitions.dart';
import '../../../core/widgets/confidence_badge.dart';
import '../../../core/widgets/proxy_shape_3d.dart';
import '../../../core/widgets/status_pill.dart';
import '../../fit_check/presentation/placement_viewer_screen.dart';

class WishlistScreen extends StatefulWidget {
  final RoomFitState state;

  const WishlistScreen({super.key, required this.state});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  FitStatus? _selectedFitFilter; // null = All
  String? _selectedRoomFilter;   // null = All Rooms

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final allItems = widget.state.wishlist;
        final rooms = widget.state.rooms;

        // Apply filters (Prompt 9 requirement: filters by fit result and by room)
        final filteredItems = allItems.where((item) {
          if (_selectedFitFilter != null && item.fitStatus != _selectedFitFilter) {
            return false;
          }
          if (_selectedRoomFilter != null && item.roomId != _selectedRoomFilter) {
            return false;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Saved Fit-Checks'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 1. Filter Chips Row: By Fit Result (Prompt 9)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFitFilterChip(label: 'All Results', status: null),
                      const SizedBox(width: 8),
                      _buildFitFilterChip(label: 'Fits', status: FitStatus.fits),
                      const SizedBox(width: 8),
                      _buildFitFilterChip(label: 'Tight', status: FitStatus.tight),
                      const SizedBox(width: 8),
                      _buildFitFilterChip(label: "Won't Fit", status: FitStatus.wontFit),
                    ],
                  ),
                ),

                // 2. Filter Chips Row: By Room (Prompt 9)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildRoomFilterChip(label: 'All Rooms', roomId: null),
                      ...rooms.map((r) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _buildRoomFilterChip(label: r.name, roomId: r.id),
                          )),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // 3. Saved Fit-Checks List
                Expanded(
                  child: filteredItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final record = filteredItems[index];
                            return Dismissible(
                              key: ValueKey(record.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0x33FF3B30),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0x66FF3B30)),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFFF5252),
                                  size: 24,
                                ),
                              ),
                              onDismissed: (_) {
                                widget.state.deleteFitCheck(record.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF1E293B),
                                    content: Text(
                                      'Removed "${record.product.title}" from saved checks',
                                      style: AppTypography.bodySmall,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: _buildWishlistCard(context, record),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFitFilterChip({required String label, required FitStatus? status}) {
    final isSelected = _selectedFitFilter == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedFitFilter = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x2E00F0FF) : const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryCyan : const Color(0x22FFFFFF),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.badge.copyWith(
            color: isSelected ? AppColors.primaryCyan : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomFilterChip({required String label, required String? roomId}) {
    final isSelected = _selectedRoomFilter == roomId;
    return GestureDetector(
      onTap: () => setState(() => _selectedRoomFilter = roomId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x2E7B2CBF) : const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFC77DFF) : const Color(0x1AFFFFFF),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? const Color(0xFFE0AAFF) : AppColors.textTertiary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistCard(BuildContext context, FitCheckRecord record) {
    final daysAgo = DateTime.now().difference(record.timestamp).inDays;
    final dateStr = daysAgo == 0
        ? 'Today'
        : daysAgo == 1
            ? 'Yesterday'
            : '$daysAgo days ago';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(16),
        hasTopGlow: true,
        onTap: () {
          // Prompt 9 requirement: Tapping a card reopens the placement viewer at its saved position!
          widget.state.restoreFitCheck(record);
          Navigator.of(context).push(
            GlassPageRoute(
              page: PlacementViewerScreen(state: widget.state),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3D Thumbnail (Prompt 9 requirement)
                Container(
                  width: 82,
                  height: 82,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0x1F141422),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x33FFFFFF)),
                  ),
                  child: ProxyShape3DPreview(
                    category: record.product.category,
                    lengthIn: record.product.lengthIn,
                    widthIn: record.product.widthIn,
                    heightIn: record.product.heightIn,
                    size: 74,
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source Tag (Online/Offline) & Date (Prompt 9 requirement)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: record.product.source == ProductSource.online
                                  ? const Color(0x2E00F0FF)
                                  : const Color(0x2E9D4EDD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              record.product.source == ProductSource.online ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: record.product.source == ProductSource.online
                                    ? AppColors.primaryCyan
                                    : const Color(0xFFD08CFF),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            dateStr,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Product Title
                      Text(
                        record.product.title,
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Room Checked Against (Prompt 9 requirement)
                      Row(
                        children: [
                          const Icon(Icons.meeting_room_outlined, size: 13, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            'Checked in: ${record.roomName}',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Dimensions
                      Text(
                        record.product.dimensionsDisplay,
                        style: AppTypography.monospace.copyWith(
                          fontSize: 11,
                          color: AppColors.primaryCyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Bottom Badges Row: Fit Result badge + Confidence indicator (Prompt 9)
            Row(
              children: [
                StatusPill(status: record.fitStatus, isCompact: true),
                const SizedBox(width: 8),
                Expanded(
                  child: ConfidenceBadge(
                    confidence: record.product.confidence,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.primaryCyan,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0x22FFFFFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 36,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text('No Fit-Checks Found', style: AppTypography.titleLarge),
            const SizedBox(height: 6),
            Text(
              'No items match the selected filters. Test a new online product or in-store scan to save fit checks.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
