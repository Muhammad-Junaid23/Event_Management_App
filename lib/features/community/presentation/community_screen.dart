import 'package:event_management_system/features/community/presentation/widgets/community_poll_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_management_system/app/config/routes.dart';
import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/features/community/providers/community_polls_provider.dart';

class CommunityScreen extends ConsumerWidget {
  final bool isAdmin;

  const CommunityScreen({super.key, this.isAdmin = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pollsAsync = ref.watch(communityPollsProvider);

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
              _buildHeader(context),
              Expanded(
                child: pollsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (polls) {
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
                          onOptionSelected: (selectedOptionId) {
                            ref
                                .read(communityPollsProvider.notifier)
                                .voteOption(poll.id, selectedOptionId);
                          },
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Tapping avatar/title directly navigates to Group Profile
          InkWell(
            onTap: () => context.push(
              AppRoutes.groupProfile,
              extra: {'groupId': 'grp_1'},
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: ClipOval(
                    child: Image.asset(
                      AppAssets.businessGroup,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Business group',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
             onPressed: () => context.push(
              AppRoutes.groupProfile,
              extra: {'groupId': 'grp_1'},
            ),
          ),
        ],
      ),
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
