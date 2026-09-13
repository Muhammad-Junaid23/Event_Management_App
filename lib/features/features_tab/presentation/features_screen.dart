import 'package:event_management_system/app/config/routes.dart';
import 'package:event_management_system/features/home/presentation/widgets/filter_bottom_sheet.dart';
import 'package:event_management_system/features/home/providers/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/core/widgets/event_card.dart';
import 'package:intl/intl.dart';

class FeaturesScreen extends ConsumerStatefulWidget {
  const FeaturesScreen({super.key});

  @override
  ConsumerState<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends ConsumerState<FeaturesScreen> {
  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterBottomSheet(provider: eventProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listens exclusively to the features provider
    final eventState = ref.watch(eventProvider);

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
              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorderInput
                              : AppColors.borderFilterIcon,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: isDark ? Colors.white : AppColors.filterIcon,
                        ),
                        onPressed: _openFilterDialog,
                      ),
                    ),
                  ],
                ),
              ),

              // Feature Cards Feed
              Expanded(
                child: eventState.filteredEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No matching events found.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: eventState.filteredEvents.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final event = eventState.filteredEvents[index];
                          final formattedDate = DateFormat(
                            'EEE, d MMM yyyy, h:mm a',
                          ).format(event.dateTime);

                          return EventCard(
                            title: event.title,
                            dateText: formattedDate,
                            locationText: event.location,
                            isFavorite: event.isFavorite,
                            // Toggles favorite in master list across all screens
                            onFavoriteTap: () {
                              ref
                                  .read(eventProvider.notifier)
                                  .toggleFavorite(event.id);
                            },
                            onTap: () {
                              context.push(
                                AppRoutes.eventDetails,
                                extra: {
                                  'eventId': event.id,
                                  'title': event.title,
                                  'dateText': formattedDate,
                                  'locationText': event.location,
                                  'isFavorite': event.isFavorite,
                                },
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
