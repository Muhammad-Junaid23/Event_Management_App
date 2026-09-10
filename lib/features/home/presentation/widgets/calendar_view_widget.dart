import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/constants/app_colors.dart';
import 'event_card.dart';

class CalendarViewWidget extends StatefulWidget {
  const CalendarViewWidget({super.key});

  @override
  State<CalendarViewWidget> createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends State<CalendarViewWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // Dynamic event filtering
  List<Color> _getDotsForDay(DateTime day) {
    // Replace with Provider or REST API event mapping logic
    List<Color> dots = [];
    if (day.day % 3 == 0) dots.add(Colors.teal);
    if (day.day % 5 == 0) dots.add(Colors.red);
    if (day.day % 2 == 0 && day.day < 20) dots.add(Colors.blue);
    return dots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header Controls
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildChevronButton(
                  icon: Icons.chevron_left,
                  isDark: isDark,
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

          // Calendar Grid
          TableCalendar<Color>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getDotsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
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
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return const SizedBox();
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.map((color) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent, // Hollow background
                          border: Border.all(
                            color: color, // Outlined color
                            width: 1.2, // Thickness of the outline
                          ),
                        ),
                      );
                    }).toList(),
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

          const EventCard(),
          const SizedBox(height: 12),
          const EventCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChevronButton({
    required IconData icon,
    required bool isDark,
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
            color: isDark ? AppColors.darkBorderInput : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
