import 'package:flutter/material.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_assets.dart';

class NotificationModel {
  final String text;
  final String time;
  final bool isUnread;

  NotificationModel({
    required this.text,
    required this.time,
    this.isUnread = false,
  });
}

class NotificationScreen extends StatelessWidget {
  final List<NotificationModel> notifications = List.generate(
    8,
    (index) => NotificationModel(
      text: 'Lorem ipsum dolor sit amet consectetur.',
      time: '4:00pm',
      isUnread: index < 3, // Top 3 matching red indicators in design
    ),
  );

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
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
                  child: Image.asset(
                    AppAssets.featuresCard,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
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
                      const SizedBox(height: 0),
                    const SizedBox(height: 8),
                    Text(
                      item.time,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
