import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';

class EventCard extends StatelessWidget {
  final Widget? topWidget;
  final String title;
  final String? dateText;
  final String? locationText;
  final Widget? actionButton;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap; // Added tap callback

  const EventCard({
    super.key,
    this.topWidget,
    required this.title,
    this.dateText,
    this.locationText,
    this.actionButton,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorderInput : AppColors.borderCard,
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image (Clickable)
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      topWidget ??
                      Container(
                        height: 220,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: Image.asset(
                          AppAssets.featuresCard,
                          fit: BoxFit.cover,
                        ),
                      ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title (Clickable)
          GestureDetector(
            onTap: onTap,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Date Row
          if (dateText != null) ...[
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: isDark ? Colors.white70 : Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  dateText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Location Row
          if (locationText != null) ...[
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: isDark ? Colors.white70 : Colors.black,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationText!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // Action Button
          if (actionButton != null) actionButton!,
        ],
      ),
    );
  }
}
