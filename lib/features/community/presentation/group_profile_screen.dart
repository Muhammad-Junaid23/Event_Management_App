import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:event_management_system/app/config/routes.dart';
import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/core/widgets/custom_image_wrapper.dart';
import 'package:event_management_system/core/widgets/event_card.dart';
import 'package:event_management_system/features/community/models/group_profile_model.dart';
import 'package:event_management_system/features/community/providers/group_profile_provider.dart';
import 'package:event_management_system/features/home/providers/event_provider.dart';

class GroupProfileScreen extends ConsumerWidget {
  final String groupId;

  const GroupProfileScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupProfileProvider(groupId));

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: 10),
          Expanded(
            child: groupAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (e, _) => _ErrorView(
                message: '$e',
                onRetry: () => ref.invalidate(groupProfileProvider(groupId)),
              ),
              data: (group) => _buildBody(context, ref, group),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return SafeArea(
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
              onPressed: () async {
                try {
                  await ref
                      .read(groupProfileProvider(groupId).notifier)
                      .toggleNotifications();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    GroupProfileState groupProfile,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Events filtering still runs against the mock event provider.
    final groupEvents =
        ref
            .watch(eventsWithFavoriteProvider)
            .value
            ?.where((e) => e.group == groupProfile.groupId)
            .toList() ??
        const [];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            children: [
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    GestureDetector(
                      onTap: () async {
                        try {
                          await ref
                              .read(groupProfileProvider(groupId).notifier)
                              .toggleJoinGroup();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        }
                      },
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
              Text(
                'Group Events',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
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
                    final formattedDate = DateFormat('dd MMMM yyyy h:mma')
                        .format(event.dateTime);

                    return EventCard(
                      title: event.title,
                      dateText: formattedDate,
                      locationText: '${event.location}, ${event.city}',
                      imagePath: event.imageUrl,
                      isFavorite: event.isFavorite,
                      onFavoriteTap: () {
                        ref.read(eventActionsProvider).toggleFavorite(event.id);
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
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: buildSmartImage(
                    groupProfile.imageUrl,
                    fit: BoxFit.cover,
                    fallbackAsset: AppAssets.businessGroup,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load group.\n$message',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textBody),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: const Text(
                  'Retry',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
