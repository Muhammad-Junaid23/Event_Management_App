import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/core/utils/cloudinary_url.dart';
import 'package:event_management_system/core/widgets/custom_image_wrapper.dart';
import 'package:event_management_system/features/community/models/community_poll_model.dart';
import 'package:flutter/material.dart';
import 'package:event_management_system/app/constants/app_colors.dart';

class CommunityPollCard extends StatelessWidget {
  final PollModel poll;
  final String imagePath;
  final String timeAgo;
  final bool isDark;
  final ValueChanged<String>? onOptionSelected;

  const CommunityPollCard({
    super.key,
    required this.poll,
    required this.imagePath,
    required this.timeAgo,
    required this.isDark,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorderInput
              : AppColors.borderCommunityCard,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: buildSmartImage(
                cloudinaryThumb(imagePath, width: 400, height: 400),
                fit: BoxFit.cover,
                fallbackAsset: AppAssets.featuresCard,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poll.question,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 14),
                Column(
                  children: List.generate(poll.options.length, (index) {
                    final option = poll.options[index];
                    final isSelected = poll.userVotedOptionId == option.id;
                    final optionLabel = '${String.fromCharCode(65 + index)}.'; // Converts 0 to A., 1 to B.

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == poll.options.length - 1 ? 0 : 12.0,
                      ),
                      child: InkWell(
                        onTap: () => onOptionSelected?.call(option.id),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              optionLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.text,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${option.votes} Votes',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
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
                    timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
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
