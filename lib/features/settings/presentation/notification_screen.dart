import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/features/settings/providers/notification_provider.dart';
import 'package:event_management_system/core/widgets/custom_image_wrapper.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Text(
          'Notification',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Create a test notifications notifier addition method or mock triggers
              ref.read(notificationProvider.notifier).addNewTestNotification();
            },
            child: const Text(
              'Add Test',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return InkWell(
            onTap: () {
              ref.read(notificationProvider.notifier).markAsRead(item.id);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: buildSmartImage(
                        item.imageUrl ?? AppAssets.featuresCard,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Notification Content
                  Expanded(
                    child: Text(
                      item.text,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  // Indicator + Timestamp
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.isUnread)
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 1),
                      const SizedBox(height: 8),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
