import 'package:flutter/material.dart';
import '../../../core/models/fit_check_record.dart';
import '../../../core/models/room_model.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_bottom_bar.dart';
import '../../../core/theme/glass_button.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/page_transitions.dart';
import '../../../core/widgets/status_pill.dart';
import '../../fit_check/presentation/placement_viewer_screen.dart';
import '../../offline_shopping/presentation/offline_entry_screen.dart';
import '../../online_shopping/presentation/online_product_screen.dart';
import '../../rooms/presentation/my_home_screen.dart';
import '../../scan_room/presentation/scan_intro_screen.dart';
import '../../wishlist/presentation/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  final RoomFitState state;

  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: GlassBottomBar(
            currentIndex: _navIndex,
            onTap: (index) {
              if (index == _navIndex) return;
              setState(() => _navIndex = index);
              if (index == 1) {
                Navigator.of(context).push(
                  GlassPageRoute(page: MyHomeScreen(state: widget.state)),
                ).then((_) => setState(() => _navIndex = 0));
              } else if (index == 2) {
                Navigator.of(context).push(
                  GlassPageRoute(page: WishlistScreen(state: widget.state)),
                ).then((_) => setState(() => _navIndex = 0));
              } else if (index == 3) {
                Navigator.of(context).push(
                  GlassPageRoute(page: ScanIntroScreen(state: widget.state)),
                ).then((_) => setState(() => _navIndex = 0));
              }
            },
            items: const [
              GlassBottomBarItem(icon: Icons.home_rounded, label: 'Home'),
              GlassBottomBarItem(icon: Icons.meeting_room_rounded, label: 'Rooms'),
              GlassBottomBarItem(icon: Icons.bookmark_added_rounded, label: 'Wishlist'),
              GlassBottomBarItem(icon: Icons.view_in_ar_rounded, label: 'Scan'),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cyanShadow,
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: const Icon(
              Icons.view_in_ar_rounded,
              size: 20,
              color: Color(0xFF001524),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RoomFit',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'OriginOS Spatial Engine',
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.primaryCyan,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.textSecondary),
            onPressed: () {
              // Quick demo toggles
              _showQuickSettingsSheet(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final rooms = widget.state.rooms;
    final wishlist = widget.state.wishlist;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
      children: [
        // Prompt 1: Top Status Card
        _buildHomeStatusCard(rooms),
        const SizedBox(height: 24),

        // Prompt 1: Two Large Equal Glass Cards
        _buildShoppingOptionsGrid(),
        const SizedBox(height: 28),

        // Quick Access: Saved Rooms Preview
        _buildSectionHeader(
          title: 'Saved Rooms',
          subtitle: '${rooms.length} configured',
          actionText: 'Manage',
          onActionTap: () {
            Navigator.of(context).push(
              GlassPageRoute(page: MyHomeScreen(state: widget.state)),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSavedRoomsHorizontal(rooms),
        const SizedBox(height: 28),

        // Quick Access: Recent Fit Checks
        if (wishlist.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Recent Fit-Checks',
            subtitle: '${wishlist.length} saved checks',
            actionText: 'View All',
            onActionTap: () {
              Navigator.of(context).push(
                GlassPageRoute(page: WishlistScreen(state: widget.state)),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildRecentFitChecks(wishlist),
        ],
      ],
    );
  }

  Widget _buildHomeStatusCard(List<RoomModel> rooms) {
    final hasRooms = rooms.isNotEmpty;

    if (!hasRooms) {
      return GlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(22),
        hasTopGlow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0x2E00F0FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x6600F0FF)),
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    color: AppColors.primaryCyan,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spatial Map Ready',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Scan your home to get started',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GlassButton(
              label: 'Scan Your First Room',
              icon: Icons.camera_alt_outlined,
              variant: GlassButtonVariant.primary,
              height: 48,
              onPressed: () {
                Navigator.of(context).push(
                  GlassPageRoute(page: ScanIntroScreen(state: widget.state)),
                );
              },
            ),
          ],
        ),
      );
    }

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      hasTopGlow: true,
      onTap: () {
        Navigator.of(context).push(
          GlassPageRoute(page: MyHomeScreen(state: widget.state)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x3300F0FF), Color(0x1A0066FF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x5500F0FF)),
                ),
                child: const Icon(
                  Icons.home_work_rounded,
                  color: AppColors.primaryCyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Home: ${rooms.length} rooms scanned',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Ready for instant 3D product fit checks',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chips of scanned rooms
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rooms.map((r) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0x22FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x2BFFFFFF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.square_foot_rounded,
                      size: 13,
                      color: AppColors.primaryCyan,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      r.name,
                      style: AppTypography.badge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      r.shortDimensions,
                      style: AppTypography.badge.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Prompt 1: Two large equal glass cards
  Widget _buildShoppingOptionsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 14) / 2;

        return Row(
          children: [
            // Card 1: Online Shopping
            SizedBox(
              width: cardWidth,
              height: 200,
              child: GlassCard(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                hasTopGlow: true,
                onTap: () {
                  Navigator.of(context).push(
                    GlassPageRoute(
                      page: OnlineProductScreen(state: widget.state),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0x2E00F0FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x5500F0FF)),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.primaryCyan,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Online Shopping',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Check if a product fits using its listed measurements',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Card 2: Offline Shopping
            SizedBox(
              width: cardWidth,
              height: 200,
              child: GlassCard(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                hasTopGlow: true,
                borderGradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x809D4EDD),
                    Color(0x2200E5FF),
                    Color(0x05FFFFFF),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    GlassPageRoute(
                      page: OfflineEntryScreen(state: widget.state),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0x2E9D4EDD),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x559D4EDD)),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Color(0xFFC77DFF),
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Offline Shopping',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Scan a product in-store to check if it fits',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.titleLarge.copyWith(fontSize: 18)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTypography.bodySmall),
          ],
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionText,
            style: AppTypography.label.copyWith(
              color: AppColors.primaryCyan,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedRoomsHorizontal(List<RoomModel> rooms) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: rooms.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == rooms.length) {
            // Add Room Card
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  GlassPageRoute(page: ScanIntroScreen(state: widget.state)),
                );
              },
              child: GlassCard(
                borderRadius: 18,
                width: 110,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0x2200F0FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x5500F0FF)),
                      ),
                      child: const Icon(Icons.add, color: AppColors.primaryCyan, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Room',
                      style: AppTypography.badge.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final room = rooms[index];
          return SizedBox(
            width: 170,
            child: GlassCard(
              borderRadius: 18,
              padding: const EdgeInsets.all(14),
              onTap: () {
                widget.state.setActiveRoom(room);
                Navigator.of(context).push(
                  GlassPageRoute(page: MyHomeScreen(state: widget.state)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.primaryCyan),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          room.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    room.shortDimensions,
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${room.ceilingHeightFt.toStringAsFixed(0)}ft Ceiling • ${room.doorways.length} doors',
                    style: AppTypography.bodySmall.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentFitChecks(List<FitCheckRecord> items) {
    return Column(
      children: items.take(3).map((record) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            onTap: () {
              widget.state.restoreFitCheck(record);
              Navigator.of(context).push(
                GlassPageRoute(
                  page: PlacementViewerScreen(state: widget.state),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0x22FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x33FFFFFF)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    record.product.category.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.product.title,
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'in ${record.roomName} • ${record.product.dimensionsDisplay}',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusPill(status: record.fitStatus, isCompact: true),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showQuickSettingsSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF14141E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Environment State', style: AppTypography.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Switch between seed states to test various conditions',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppColors.primaryCyan),
                  title: const Text('Reset Rooms to 3 (Default)'),
                  onTap: () {
                    Navigator.pop(c);
                    widget.state.clearAllRooms();
                    widget.state.addRoom(RoomModel(
                      id: 'r1',
                      name: 'Living Room',
                      lengthFt: 16.5,
                      widthFt: 14.0,
                      scannedDate: DateTime.now(),
                    ));
                    widget.state.addRoom(RoomModel(
                      id: 'r2',
                      name: 'Primary Bedroom',
                      lengthFt: 13.0,
                      widthFt: 11.5,
                      scannedDate: DateTime.now(),
                    ));
                    widget.state.addRoom(RoomModel(
                      id: 'r3',
                      name: 'Study',
                      lengthFt: 11.0,
                      widthFt: 9.5,
                      scannedDate: DateTime.now(),
                    ));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_sweep, color: AppColors.statusAmber),
                  title: const Text('Simulate 0 Rooms Scanned'),
                  onTap: () {
                    Navigator.pop(c);
                    widget.state.clearAllRooms();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
