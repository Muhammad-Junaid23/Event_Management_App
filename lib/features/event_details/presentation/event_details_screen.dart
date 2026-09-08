import 'package:flutter/material.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_assets.dart';

class EventDetailsScreen extends StatelessWidget {
  final String title;
  final String dateText;
  final String locationText;
  final String description;
  final String imagePath;

  const EventDetailsScreen({
    super.key,
    this.title = 'Made in Melanin! Black History Month Social.....',
    this.dateText = '28 October 2025 6:00pm GMT',
    this.locationText = '1901 Thornridge Cir. Shiloh, Hawaii 81063',
    this.description = 'Lorem ipsum dolor sit amet consectetur. Sed volutpat euismod enim accumsan quam posuere. Tortor pretium lorem dui metus amet in sed. Sodales volutpat maecenas et quisque nibh ultrices in nulla. Enim fames quam turpis pellentesque vivamus massa.Lorem ipsum dolor sit amet consectetur. Sed volutpat euismod enim accumsan quam posuere. Tortor pretium lorem dui metus amet in sed. Sodales volutpat maecenas et quisque nibh ultrices in nulla.Lorem ipsum dolor sit amet consectetur. Sed volutpat euismod enim accumsan',
    this.imagePath = AppAssets.featuresCard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Fallback in case passed description is empty or whitespace
    final String displayText = (description.trim().isNotEmpty)
        ? description
        : 'Lorem ipsum dolor sit amet consectetur. Sed volutpat euismod enim accumsan quam posuere. Tortor pretium lorem dui metus amet in sed. Sodales volutpat maecenas et quisque nibh ultrices in nulla. Enim fames quam turpis pellentesque vivamus massa.';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header Image + Controls Overlay
                  Stack(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.40,
                        width: double.infinity,
                        child: Image.asset(
                          imagePath.isNotEmpty
                              ? imagePath
                              : AppAssets.featuresCard,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. Main Details Body
                  Transform.translate(
                    offset: const Offset(0, -16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Date Row
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dateText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Location Row
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  locationText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Event Detail Header
                          Text(
                            'Event Detail',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Description Container with Forced Visible Text Style
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBorderInput
                                  : const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              displayText,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF666666),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Fixed Bottom Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
