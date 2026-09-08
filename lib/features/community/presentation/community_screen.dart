import 'package:event_management_system/app/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_assets.dart';

// -----------------------------------------------------------------------------
// Poll Data Model
// -----------------------------------------------------------------------------
class PollOption {
  final String label;
  final String title;
  final String votes;

  const PollOption({
    required this.label,
    required this.title,
    required this.votes,
  });
}

class CommunityPoll {
  final String id;
  final String imagePath;
  final String title;
  final List<PollOption> options;
  final String timeAgo;

  const CommunityPoll({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.options,
    required this.timeAgo,
  });
}

// -----------------------------------------------------------------------------
// Main Community Screen
// -----------------------------------------------------------------------------
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  final List<CommunityPoll> _polls = const [
    CommunityPoll(
      id: 'poll_1',
      imagePath: AppAssets.featuresCard,
      title: 'Made in Melanin! Black History Month Social',
      timeAgo: '12hr ago',
      options: [
        PollOption(
          label: 'A.',
          title: 'Made in Melanin! Black History Month Social',
          votes: '12k Votes',
        ),
        PollOption(
          label: 'B.',
          title: 'Made in Melanin! Black History Month Social',
          votes: '12k Votes',
        ),
      ],
    ),
    CommunityPoll(
      id: 'poll_2',
      imagePath: AppAssets.featuresCard,
      title: 'Annual Tech Innovators Meetup 2026',
      timeAgo: '5hr ago',
      options: [
        PollOption(
          label: 'A.',
          title: 'In-Person Networking Session',
          votes: '8k Votes',
        ),
        PollOption(
          label: 'B.',
          title: 'Virtual Livestream & Q&A',
          votes: '15k Votes',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
              // Header
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        context.push(AppRoutes.groupProfile);
                      },
                    ),
                  ],
                ),
              ),

              // Community List Feed
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: _polls.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textCardSubtitle,
                            ),
                          ),
                        ),
                      );
                    }

                    final poll = _polls[index - 1];
                    return CommunityPollCard(
                      key: ValueKey(poll.id), // Explicit unique key per card
                      poll: poll,
                      isDark: isDark,
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
}

// -----------------------------------------------------------------------------
// Individual Poll Card Widget
// -----------------------------------------------------------------------------
class CommunityPollCard extends StatefulWidget {
  final CommunityPoll poll;
  final bool isDark;

  const CommunityPollCard({
    super.key,
    required this.poll,
    required this.isDark,
  });

  @override
  State<CommunityPollCard> createState() => _CommunityPollCardState();
}

class _CommunityPollCardState extends State<CommunityPollCard> {
  int _selectedOptionIndex = 0; // Independent state instance

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark
              ? AppColors.darkBorderInput
              : AppColors.borderCommunityCard,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.asset(widget.poll.imagePath, fit: BoxFit.cover),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.poll.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 14),

                // Render Poll Options using Column instead of nested ListView
                Column(
                  children: List.generate(widget.poll.options.length, (optIdx) {
                    final option = widget.poll.options[optIdx];
                    final isSelected = _selectedOptionIndex == optIdx;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: optIdx == widget.poll.options.length - 1
                            ? 0
                            : 12.0,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedOptionIndex = optIdx;
                          });
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Radio Button Indicator
                            Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.borderFilterIcon,
                                  width: 1.2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),

                            // Title & Vote Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: widget.isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    option.votes,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: widget.isDark
                                          ? Colors.white54
                                          : AppColors.textCardSubtitle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    widget.poll.timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.isDark
                          ? Colors.white54
                          : AppColors.textCardSubtitle,
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
