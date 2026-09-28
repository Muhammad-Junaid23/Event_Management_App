import 'package:event_management_system/core/utils/error_messages.dart';
import 'package:event_management_system/core/widgets/event_search_field.dart';
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
              const SizedBox(height: 16),

              Expanded(
                child: _selectedView == 0
                    ? const CalendarViewWidget()
                    : ref
                          .watch(filteredEventsProvider(EventFilterScope.home))
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
                                final query = ref.watch(searchQueryProvider);
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
