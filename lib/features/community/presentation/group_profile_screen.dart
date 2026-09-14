import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/core/widgets/event_card.dart';
import 'package:event_management_system/features/community/providers/community_provider.dart';

class GroupProfileScreen extends ConsumerWidget {
  const GroupProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupState = ref.watch(groupProfileProvider);
    final groupNotifier = ref.read(groupProfileProvider.notifier);

    final formattedCount = groupState.memberCount >= 1000
        ? '${(groupState.memberCount / 1000).toStringAsFixed(0)}K Members'
        : '${groupState.memberCount} Members';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.bgPattern),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
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
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'mute') groupNotifier.toggleMuteGroup();
                        if (value == 'join') groupNotifier.toggleJoinGroup();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'join',
                          child: Text(
                            groupState.isJoined ? 'Leave Group' : 'Join Group',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'mute',
                          child: Text(
                            groupState.isMuted
                                ? 'Unmute Notifications'
                                : 'Mute Notifications',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
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
                        Center(
                          child: Column(
                            children: [
                              Text(
                                groupState.name,
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
                                  groupState.description,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textCardSubtitle,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFECEC),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      formattedCount,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () =>
                                        groupNotifier.toggleJoinGroup(),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: Text(
                                      groupState.isJoined ? 'Joined' : 'Join',
                                      style: TextStyle(
                                        color: groupState.isJoined
                                            ? Colors.grey
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Group Events',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Dynamic Events List linked with backend-ready State
                        if (groupState.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (groupState.events.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text('No events found for this group'),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupState.events.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final event = groupState.events[index];
                              // Simple date formatting matching original mock UI string
                              final dateText =
                                  '${event.dateTime.day} October ${event.dateTime.year} ${event.dateTime.hour}:00pm GMT';

                              return EventCard(
                                title: event.title,
                                dateText: dateText,
                                locationText: event.location,
                                isFavorite: event.isFavorite,
                                actionButton: SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: () {},
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

                  // Positioned Avatar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ClipOval(
                        child: Image.asset(
                          groupState.imageUrl,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
