import 'package:flutter/material.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_assets.dart';
import 'widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedView = 0; // 0: Calendar View, 1: List View
  DateTime _focusedDay = DateTime(2025, 9, 1);
  DateTime? _selectedDay = DateTime(2025, 9, 2);

  // Filter Dialog (Fix 11: Covers root navigator to block bottom navigation interactions)
  void _openFilterDialog() {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (context) => const FilterBottomSheet(),
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
                    // Outlined Filter Icon (Fix 3)
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

              // Main Dynamic View Switcher (Fix 1 & 2)
              Expanded(
                child: _selectedView == 0
                    ? _buildCalendarView(theme, isDark)
                    : _buildListView(theme, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CALENDAR VIEW BUILDER
  Widget _buildCalendarView(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Dynamic Month/Year Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {
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
                    _getMonthName(_focusedDay.month),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  // Muted Year Text Color (Fix 4)
                  Text(
                    '${_focusedDay.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.calendarYearDay,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {
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
          const SizedBox(height: 12),

          // Interactive Calendar Grid (Fix 1)
          _buildInteractiveCalendarGrid(theme, isDark),
          const SizedBox(height: 16),

          // Calendar Divider (Fix 5)
          Divider(
            color: isDark ? AppColors.darkBorderInput : AppColors.borderDivider,
            thickness: 0.5,
          ),
          const SizedBox(height: 16),

          // Event Cards List for Selected Date
          _buildEventCard(theme, isDark),
          const SizedBox(height: 12),
          _buildEventCard(theme, isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // LIST VIEW BUILDER (Fix 2)
  Widget _buildListView(ThemeData theme, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildEventCard(theme, isDark);
      },
    );
  }

  Widget _buildInteractiveCalendarGrid(ThemeData theme, bool isDark) {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );
    final firstDayOffset =
        DateTime(_focusedDay.year, _focusedDay.month, 1).weekday - 1;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays
              .map(
                (d) => Text(
                  d,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.calendarYearDay,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 35,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final dayNumber = index - firstDayOffset + 1;
            final isCurrentMonthDay = dayNumber > 0 && dayNumber <= daysInMonth;

            if (!isCurrentMonthDay) {
              return Center(
                child: Text(
                  '${dayNumber <= 0 ? 30 + dayNumber : dayNumber - daysInMonth}',
                  style: const TextStyle(
                    color: AppColors.calendarYearDay,
                    fontSize: 13,
                  ),
                ),
              );
            }

            final currentCellDate = DateTime(
              _focusedDay.year,
              _focusedDay.month,
              dayNumber,
            );
            final isSelected =
                _selectedDay != null &&
                _selectedDay!.year == currentCellDate.year &&
                _selectedDay!.month == currentCellDate.month &&
                _selectedDay!.day == currentCellDate.day;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = currentCellDate;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (dayNumber == 2 || dayNumber == 13 || dayNumber == 22)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircleAvatar(radius: 2, backgroundColor: Colors.cyan),
                        SizedBox(width: 2),
                        CircleAvatar(radius: 2, backgroundColor: Colors.red),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventCard(ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tech Meetup',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      // Card Date & Time Muted Color Fix (Fix 6)
                      const Text(
                        'Wed, 5 Nov 2025, 2:00PM - 3:00PM',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textCardSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: AppColors.textCardSubtitle,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '2464 Royal Ln. Mesa, New Jersey 45463',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Add to my calendar',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
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

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
