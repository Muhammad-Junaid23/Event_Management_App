import 'package:event_management_system/core/repositories/auth_repository.dart';
import 'package:event_management_system/core/utils/error_messages.dart';
import 'package:event_management_system/core/widgets/event_search_field.dart';
import 'package:event_management_system/features/auth/providers/auth_provider.dart';
import 'package:event_management_system/features/home/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/features/home/presentation/widgets/calendar_view_widget.dart';
import 'package:event_management_system/features/home/presentation/widgets/event_card.dart';

import 'widgets/filter_bottom_sheet.dart';

import 'package:event_management_system/features/home/providers/event_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedView = 0; // 0: Calendar View, 1: List View

  void _openFilterDialog() {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (context) =>
          const FilterBottomSheet(scope: EventFilterScope.home),
    );
  }

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
              // Header Row
              const _EmailVerificationBanner(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Events',
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
                          Icons.tune,
                          size: 20,
                          color: isDark ? Colors.white : AppColors.filterIcon,
                        ),
                        onPressed: _openFilterDialog,
                      ),
                    ),
                  ],
                ),
              ),

              // Search — NEW
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: EventSearchField(),
              ),
              const SizedBox(height: 12),

              // View Selector Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.tileBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton('Calendar View', 0, isDark),
                      _buildToggleButton('List View', 1, isDark),
                    ],
                  ),
                ),
              ),

              // RSVP filter chip
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Consumer(
                  builder: (context, ref, _) {
                    final showOnlyRsvps = ref.watch(showRsvpsOnlyProvider);
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: FilterChip(
                        label: Text(
                          'Going (${ref.watch(myRsvpsProvider).value?.length ?? 0})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: showOnlyRsvps
                                ? Colors.white
                                : AppColors.textMain,
                          ),
                        ),
                        selected: showOnlyRsvps,
                        onSelected: (_) =>
                            ref.read(showRsvpsOnlyProvider.notifier).toggle(),
                        backgroundColor: isDark
                            ? AppColors.darkSurface
                            : AppColors.tileBackground,
                        selectedColor: AppColors.primary,
                        showCheckmark: false,
                        side: BorderSide(
                          color: showOnlyRsvps
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkBorderInput
                                    : AppColors.borderFilterIcon),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

             Expanded(
                child: _selectedView == 0
                    ? const CalendarViewWidget()
                    : Consumer(
                        builder: (context, ref, _) {
                          final showOnlyRsvps = ref.watch(
                            showRsvpsOnlyProvider,
                          );

                          // When the "Going" chip is on, bypass filters entirely and use
                          // the RSVP list directly.
                          if (showOnlyRsvps) {
                            final rsvps =
                                ref.watch(myRsvpsProvider).value ??
                                const <EventModel>[];
                            if (rsvps.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    "You haven't RSVP'd to any events yet.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textCardSubtitle,
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
                              itemCount: rsvps.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) =>
                                  EventCard(event: rsvps[index]),
                            );
                          }

                          // Otherwise, the normal filtered list.
                          return ref
                              .watch(
                                filteredEventsProvider(EventFilterScope.home),
                              )
                              .when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
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
                                      Text(
                                        friendlyError(e),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () =>
                                            ref.invalidate(eventsProvider),
                                        child: const Text(
                                          'Retry',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                data: (events) {
                                  if (events.isEmpty) {
                                    final query = ref.watch(
                                      searchQueryProvider,
                                    );
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Text(
                                          query.isEmpty
                                              ? 'No matching events found'
                                              : 'No events match "$query"',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: AppColors.textCardSubtitle,
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
                                    itemCount: events.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) =>
                                        EventCard(event: events[index]),
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

  Widget _buildToggleButton(String title, int index, bool isDark) {
    final isSelected = _selectedView == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedView = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextBody : AppColors.textSubtle),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailVerificationBanner extends ConsumerWidget {
  const _EmailVerificationBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifiedAsync = ref.watch(emailVerifiedProvider);
    final verified = verifiedAsync.value ?? true; // hide while loading

    if (verified) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade800, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Please verify your email to unlock all features.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(authRepositoryProvider);
              try {
                await repo.resendVerificationEmail();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Verification email sent. Check your inbox.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            child: const Text(
              'Resend',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
