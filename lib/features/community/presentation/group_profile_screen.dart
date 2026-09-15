import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:event_management_system/app/config/routes.dart';

import 'package:event_management_system/app/constants/app_assets.dart';

import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/features/community/providers/group_profile_provider.dart';
import 'package:event_management_system/features/home/providers/event_provider.dart';
import 'package:event_management_system/core/widgets/event_card.dart';

class GroupProfileScreen extends ConsumerWidget {
  final String groupName;

  const GroupProfileScreen({super.key, this.groupName = 'Business group'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch dynamic state from group profile provider
    final groupProfile = ref.watch(groupProfileProvider);
    final groupProfileNotifier = ref.read(groupProfileProvider.notifier);

    // Dynamic events filtering from master event provider
    final eventState = ref.watch(eventProvider);
    final groupEvents = eventState.allEvents
        .where((e) => e.group.toLowerCase() == groupName.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // 1. Red Header Navigation Bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const Text(
                        'Group Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      // Toggle notifications/mute state
                      groupProfileNotifier.toggleNotifications();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 2. White Sheet Container with Overlapping Circle Avatar
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main Rounded White/Dark Sheet
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    children: [
                      // Group Name, Description & Member Badge
                      Center(
                        child: Column(
                          children: [
                            Text(
                              groupProfile.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                groupProfile.description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textCardSubtitle,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Member Badge (Clickable to toggle Join/Leave)
                            GestureDetector(
                              onTap: () =>
                                  groupProfileNotifier.toggleJoinGroup(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: groupProfile.isJoined
                                      ? AppColors.primary
                                      : const Color(0xFFFFECEC),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  groupProfile.isJoined
                                      ? 'Joined • ${(groupProfile.memberCount / 1000).toStringAsFixed(0)}K Members'
                                      : '${(groupProfile.memberCount / 1000).toStringAsFixed(0)}K Members',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: groupProfile.isJoined
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section Title
                      Text(
                        'Group Events',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Events List Implementation
                      if (groupEvents.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              'No events found for this group.',
                              style: TextStyle(
                                color: AppColors.textCardSubtitle,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: groupEvents.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final event = groupEvents[index];
                            final formattedDate = DateFormat(
                              'dd MMMM yyyy h:mma',
                            ).format(event.dateTime);

                            return EventCard(
                              title: event.title,
                              dateText: formattedDate,
                              locationText: '${event.location}, ${event.city}',
                              imagePath: event.imageUrl,
                              isFavorite: event.isFavorite,
                              onFavoriteTap: () {
                                ref
                                    .read(eventProvider.notifier)
                                    .toggleFavorite(event.id);
                              },
                              actionButton: SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.push(
                                      AppRoutes.eventDetails,
                                      extra: {'eventId': event.id},
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Add to my calendar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // Group Profile Picture Overlapping Top Radius
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          groupProfile.imageUrl.isNotEmpty
                              ? groupProfile.imageUrl
                              : AppAssets.businessGroup,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
