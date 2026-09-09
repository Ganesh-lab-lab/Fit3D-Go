import 'package:flutter/material.dart';
import '../../../core/models/room_model.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_button.dart';
import '../../../core/theme/glass_card.dart';
import '../../../core/theme/page_transitions.dart';
import '../../scan_room/presentation/scan_ar_camera_screen.dart';
import '../../scan_room/presentation/scan_intro_screen.dart';
import '../widgets/room_thumbnail_painter.dart';

class MyHomeScreen extends StatelessWidget {
  final RoomFitState state;

  const MyHomeScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final rooms = state.rooms;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('My Home'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Header info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${rooms.length} Scanned Rooms',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Total: ${rooms.fold<double>(0, (sum, r) => sum + r.areaSqFt).toStringAsFixed(0)} sq ft',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryCyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rooms List
                Expanded(
                  child: rooms.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          physics: const BouncingScrollPhysics(),
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            return _buildRoomCard(context, room);
                          },
                        ),
                ),
              ],
            ),
          ),
          // Floating Add Room Button at bottom
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: GlassButton(
              label: 'Add Room',
              icon: Icons.add_rounded,
              variant: GlassButtonVariant.primary,
              height: 54,
              onPressed: () {
                Navigator.of(context).push(
                  GlassPageRoute(page: ScanIntroScreen(state: state)),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0x2200F0FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.meeting_room_outlined,
                  size: 36,
                  color: AppColors.primaryCyan,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Rooms Scanned Yet',
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Scan your first room to enable real-time 3D furniture placement and collision testing.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GlassButton(
                label: 'Scan Room Now',
                icon: Icons.view_in_ar_rounded,
                variant: GlassButtonVariant.primary,
                onPressed: () {
                  Navigator.of(context).push(
                    GlassPageRoute(page: ScanIntroScreen(state: state)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, RoomModel room) {
    final daysAgo = DateTime.now().difference(room.scannedDate).inDays;
    final dateStr = daysAgo == 0
        ? 'Scanned Today'
        : daysAgo == 1
            ? 'Scanned Yesterday'
            : 'Scanned $daysAgo days ago';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(16),
        hasTopGlow: true,
        onTap: () {
          state.setActiveRoom(room);
        },
        child: Row(
          children: [
            // Thumbnail of room mesh / floor plan (Prompt 3 requirement)
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0x1F141422),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: RoomThumbnailPainter(
                    lengthFt: room.lengthFt,
                    widthFt: room.widthFt,
                    doorways: room.doorways,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Room info: name, dimensions, last-scanned date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.dimensionsDisplay,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryCyan,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Rescan Icon button (Prompt 3 requirement)
            Column(
              children: [
                IconButton(
                  tooltip: 'Rescan Room',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0x2200F0FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x4400F0FF)),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primaryCyan,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    // Quick Rescan action
                    Navigator.of(context).push(
                      GlassPageRoute(
                        page: ScanArCameraScreen(state: state),
                      ),
                    );
                  },
                ),
                Text(
                  'Rescan',
                  style: AppTypography.badge.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
