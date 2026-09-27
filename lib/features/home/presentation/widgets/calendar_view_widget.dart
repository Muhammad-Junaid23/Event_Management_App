import 'package:event_management_system/core/utils/error_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/features/home/models/event_model.dart';
import 'package:event_management_system/features/home/providers/event_provider.dart';

import 'event_card.dart';

class CalendarViewWidget extends ConsumerStatefulWidget {
  const CalendarViewWidget({super.key});

  @override
  ConsumerState<CalendarViewWidget> createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends ConsumerState<CalendarViewWidget> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredAsync = ref.watch(
      filteredEventsProvider(EventFilterScope.home),
    );
    final selectedDate = ref.watch(selectedDateProvider);
    final eventsForSelectedDayAsync = ref.watch(selectedDateEventsProvider);
    final allFilteredEvents = filteredAsync.value ?? const <EventModel>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildChevronButton(
                  icon: Icons.chevron_left,
                  isDark: isDark,
                  theme: theme,
                  onTap: () => setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                    );
                  }),
                ),
                Column(
                  children: [
                    Text(
                      DateFormat('MMMM').format(_focusedDay),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      DateFormat('yyyy').format(_focusedDay),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textCardSubtitle,
                      ),
                    ),
                  ],
                ),
                _buildChevronButton(
                  icon: Icons.chevron_right,
                  isDark: isDark,
                  theme: theme,
                  onTap: () => setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 1,
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TableCalendar<EventModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            eventLoader: (day) {
              return allFilteredEvents.where((e) {
                return e.dateTime.year == day.year &&
                    e.dateTime.month == day.month &&
                    e.dateTime.day == day.day;
              }).toList();
            },
            onDaySelected: (selectedDay, focusedDay) {
              ref.read(selectedDateProvider.notifier).set(selectedDay);
              setState(() => _focusedDay = focusedDay);
            },
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textCardSubtitle,
              ),
              weekendStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textCardSubtitle,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,
              outsideTextStyle: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              defaultTextStyle: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
              weekendTextStyle: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, dayEvents) {
                if (dayEvents.isEmpty) return const SizedBox();
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      dayEvents.length > 3 ? 3 : dayEvents.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: isDark ? AppColors.darkBorderInput : AppColors.borderDivider,
            thickness: 0.5,
          ),
          const SizedBox(height: 16),
          eventsForSelectedDayAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(friendlyError(e)),
            ),
            data: (eventsForSelectedDay) {
              if (eventsForSelectedDay.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: AppColors.textCardSubtitle,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No events found for this date',
                        style: TextStyle(
                          color: AppColors.textCardSubtitle,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: eventsForSelectedDay
                    .map(
                      (event) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: EventCard(event: event),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChevronButton({
    required IconData icon,
    required bool isDark,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorderInput
                : AppColors.borderFilterIcon,
          ),
        ),
        child: Icon(icon, size: 18, color: theme.colorScheme.onSurface),
      ),
    );
  }
}
