import 'package:event_management_system/core/widgets/custom_image_wrapper.dart';
import 'package:event_management_system/features/community/models/group_profile_model.dart';
import 'package:event_management_system/features/community/presentation/widgets/community_poll_card.dart';
import 'package:event_management_system/features/community/providers/groups_provider.dart';
import 'package:event_management_system/features/settings/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_management_system/app/config/routes.dart';
import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/features/community/providers/community_polls_provider.dart';
import 'package:event_management_system/core/utils/error_messages.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGroup = ref.watch(currentGroupProvider);
    final groupId = currentGroup?.groupId ?? '';

    // If no selection yet and groups loaded, default to first.
    if (groupId.isNotEmpty && ref.read(selectedGroupProvider) == null) {
      // Safe to call after frame; defer to avoid modifying during build.
      Future.microtask(
        () => ref.read(selectedGroupProvider.notifier).select(groupId),
      );
    }

    final pollsAsync = ref.watch(communityPollsProvider(groupId));
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      floatingActionButton: isAdmin ? _buildAdminFab(context) : null,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.bgPattern),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, ref),
              Expanded(
                child: pollsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        friendlyError(err),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  data: (polls) {
                    if (polls.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'No polls in this group yet.\n${isAdmin ? 'Tap "Vote" to create one.' : ''}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textCardSubtitle,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: polls.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildDateHeader(isDark);

                        final poll = polls[index - 1];
                        return CommunityPollCard(
                          key: ValueKey(poll.id),
                          poll: poll,
                          imagePath:
                              (poll.imageUrl != null &&
                                  poll.imageUrl!.isNotEmpty)
                              ? poll.imageUrl!
                              : AppAssets.featuresCard,
                          timeAgo: '12hr ago',
                          isDark: isDark,
                          onOptionSelected: (selectedOptionId) async {
                            try {
                              await ref
                                  .read(communityPollsActionsProvider)
                                  .vote(poll.id, selectedOptionId);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Vote failed: $e')),
                                );
                              }
                            }
                          },
                          onDelete: isAdmin
                              ? () => _confirmDeletePoll(context, ref, poll.id)
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeletePoll(
    BuildContext context,
    WidgetRef ref,
    String pollId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete poll?'),
        content: const Text('Votes will be lost. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(communityPollsActionsProvider).delete(pollId);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Poll deleted')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${friendlyError(e)}')),
        );
      }
    }
  }

  Widget _buildAdminFab(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: 'voteBtn',
          onPressed: () => context.push(AppRoutes.createVote),
          icon: const Icon(Icons.how_to_vote, color: Colors.white),
          label: const Text('Vote', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primary,
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          heroTag: 'eventBtn',
          onPressed: () => context.push(AppRoutes.createEvent),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Event', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(allGroupsProvider);
    final current = ref.watch(currentGroupProvider);

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => _showGroupPicker(context, ref),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: ClipOval(
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: buildSmartImage(
                          current?.imageUrl ?? '',
                          fit: BoxFit.cover,
                          fallbackAsset: AppAssets.businessGroup,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    current?.name ??
                        (groupsAsync.isLoading ? 'Loading…' : 'No groups'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              final id = current?.groupId;
              if (id == null) return;
              context.push(AppRoutes.groupProfilePath(id));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showGroupPicker(BuildContext context, WidgetRef ref) async {
    final groups =
        ref.read(allGroupsProvider).value ?? const <GroupProfileState>[];
    if (groups.isEmpty) return;
    final selectedId = ref.read(selectedGroupProvider);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Switch group',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        for (final g in groups)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryTransparent,
                              child: ClipOval(
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: buildSmartImage(
                                    g.imageUrl,
                                    fit: BoxFit.cover,
                                    fallbackAsset: AppAssets.businessGroup,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              g.name,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              '${(g.memberCount / 1000).toStringAsFixed(0)}K members',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextBody
                                    : AppColors.textCardSubtitle,
                              ),
                            ),
                            trailing: g.groupId == selectedId
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () {
                              ref
                                  .read(selectedGroupProvider.notifier)
                                  .select(g.groupId);
                              Navigator.pop(ctx);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Today',
          style: TextStyle(fontSize: 11, color: AppColors.textCardSubtitle),
        ),
      ),
    );
  }
}
