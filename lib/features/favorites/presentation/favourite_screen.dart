import 'package:event_management_system/app/config/routes.dart';
import 'package:event_management_system/core/utils/error_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/core/widgets/event_card_compact.dart';
import 'package:event_management_system/features/home/providers/event_provider.dart';
import 'package:intl/intl.dart';

class FavouriteScreen extends ConsumerWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
                child: ref
                    .watch(favoriteEventsProvider)
                    .when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(friendlyError(e), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => ref.invalidate(eventsProvider),
                              child: const Text(
                                'Retry',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      data: (favoriteEvents) {
                        if (favoriteEvents.isEmpty) {
                          return Center(
                            child: Text(
                              'No favorite events yet!',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
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
                            return EventCardCompact(
                              title: event.title,
                              dateText: formattedDate,
                              locationText: event.location,
                              isFavorite: event.isFavorite,
                              imagePath: event.imageUrl,
                              onFavoriteTap: () => ref
                                  .read(eventActionsProvider)
                                  .toggleFavorite(event.id),
                              onTap: () => context.push(
                                AppRoutes.eventDetailsPath(event.id),
                              ),
                              actionButton: SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(eventActionsProvider)
                                          .toggleRsvp(event.id);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('Failed: $e')),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: event.isRsvped
                                        ? Colors.green.shade700
                                        : AppColors.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    event.isRsvped
                                        ? 'Attending ✓'
                                        : 'Add to my calendar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
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
}
