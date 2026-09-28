import 'package:event_management_system/app/config/routes.dart';
import 'package:event_management_system/core/utils/cloudinary_url.dart';
import 'package:event_management_system/features/home/providers/event_provider.dart';
import 'package:event_management_system/features/settings/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:event_management_system/core/widgets/custom_image_wrapper.dart';

class EventDetailsScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    final eventsAsync = ref.watch(eventsWithFavoriteProvider);

    final event = eventsAsync.maybeWhen(
      data: (events) {
        final idx = events.indexWhere((e) => e.id == eventId);
        return idx == -1 ? null : events[idx];
      },
      orElse: () => null,
    );

    if (eventsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Event not found')),
      );
    }

    final formattedDate = DateFormat('EEE, d MMM yyyy, h:mm a')
        .format(event.dateTime);

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
                        height: screenHeight * 0.35,
                        width: double.infinity,
                        child: buildSmartImage(
                          cloudinaryThumb(
                            event.imageUrl,
                            width: 800,
                            height: 500,
                          ),
                          fit: BoxFit.cover,
                          fallbackAsset: AppAssets.featuresCard,
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => context.pop(),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  event.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: event.isFavorite
                                      ? Colors.red
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  ref
                                      .read(eventActionsProvider)
                                      .toggleFavorite(event.id);
                                },
                              ),
                              if (ref.watch(isAdminProvider))
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      context.push(
                                        AppRoutes.createEvent,
                                        extra: {'eventId': event.id},
                                      );
                                    } else if (value == 'delete') {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete event?'),
                                          content: const Text(
                                            'This cannot be undone. The event will be removed for all users.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed != true) return;

                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      final router = GoRouter.of(context);
                                      final eventId = event.id;

                                      // Pop first so EventDetails doesn't flash "not found".
                                      router.pop();

                                      try {
                                        await ref
                                            .read(eventActionsProvider)
                                            .delete(eventId);
                                      } catch (e) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to delete: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: AppColors.primary,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                            event.title,
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
                                formattedDate,
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
                                  '${event.location}, ${event.city}',
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

                          // Description Container
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
                              event.description.isNotEmpty
                                  ? event.description
                                  : 'No description provided.',
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
