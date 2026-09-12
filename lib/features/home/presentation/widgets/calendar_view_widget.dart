import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/constants/app_colors.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
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

    // 1. Read state & events directly from Riverpod
    final eventState = ref.watch(eventProvider);
    final eventsForSelectedDay = ref.watch(selectedDateEventsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header Controls (Month & Year display with Chevrons)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildChevronButton(
                  icon: Icons.chevron_left,
                  isDark: isDark,
                  theme: theme,
                  onTap: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month - 1,
                      );
                    });
                  },
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
                  onTap: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Table Calendar
          TableCalendar<EventModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,

            // Sync selected date with Riverpod
            selectedDayPredicate: (day) =>
                isSameDay(eventState.selectedDate, day),

            // Fetch actual events from Riverpod state per day
            eventLoader: (day) {
              return ref.read(eventProvider).getEventsForDay(day);
            },

            // Handle day tap: update Riverpod state
            onDaySelected: (selectedDay, focusedDay) {
              ref.read(eventProvider.notifier).setSelectedDate(selectedDay);
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
                color: theme.colorScheme.onSurface.withOpacity(0.3),
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
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),

            // Custom ring markers matching your design styling
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

          // Events list for selected day / Empty state handling
          if (eventsForSelectedDay.isEmpty)
            const Padding(
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
            )
          else
            ...eventsForSelectedDay.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: EventCard(event: event),
              ),
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
