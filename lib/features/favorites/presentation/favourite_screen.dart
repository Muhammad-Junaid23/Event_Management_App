import 'package:event_management_system/app/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/core/widgets/event_card.dart';
import 'package:event_management_system/features/home/providers/event_provider.dart';
import 'package:intl/intl.dart';

class FavouriteScreen extends ConsumerWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteEvents = ref.watch(favoriteEventsProvider);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Text(
                  'Favorite',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),

              // Favorites List Feed
              Expanded(
                child: favoriteEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No favorite events yet!',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: favoriteEvents.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final event = favoriteEvents[index];
                          final formattedDate = DateFormat(
                            'EEE, d MMM yyyy, h:mm a',
                          ).format(event.dateTime);

                          return EventCard(
                            title: event.title,
                            dateText: formattedDate,
                            locationText: event.location,
                            isFavorite: event.isFavorite,
                            imagePath: event.imageUrl,
                            onFavoriteTap: () {
                              ref
                                  .read(eventProvider.notifier)
                                  .toggleFavorite(event.id);
                            },
                            onTap: () {
                              context.push(
                                AppRoutes.eventDetails,
                                extra: {'eventId': event.id},
                              );
                            },
                            actionButton: SizedBox(
                              width: double.infinity,
                              height: 44,
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
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
