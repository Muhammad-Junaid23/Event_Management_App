import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/event_provider.dart';
import '../../../../app/constants/app_colors.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  String? selectedCity;
  String? selectedState;
  String? selectedGroup;
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Religious', 'icon': Icons.nightlight_round},
    {'name': 'Business', 'icon': Icons.business},
    {'name': 'Sports', 'icon': Icons.directions_run},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Community', 'icon': Icons.groups},
  ];

  @override
  void initState() {
    super.initState();
    final currentState = ref.read(eventProvider);
    selectedCity = currentState.selectedCity;
    selectedState = currentState.selectedState;
    selectedGroup = currentState.selectedGroup;
    selectedCategory = currentState.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Filter Events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 16),

              _buildDropdownLabel('City', theme),
              _buildDropdown(
                hint: 'Select City',
                value: selectedCity,
                items: [
                  'New York',
                  'Mesa',
                  'Los Angeles',
                  'San Francisco',
                  'Austin',
                ],
                onChanged: (val) => setState(() => selectedCity = val),
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              _buildDropdownLabel('State', theme),
              _buildDropdown(
                hint: 'Select State',
                value: selectedState,
                items: ['New Jersey', 'New York', 'California'],
                onChanged: (val) => setState(() => selectedState = val),
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              _buildDropdownLabel('Groups', theme),
              _buildDropdown(
                hint: 'Group',
                value: selectedGroup,
                items: [
                  'Group A',
                  'Group B',
                  'Tech Group',
                  'Dev Community',
                  'Business Leaders',
                  'Local Tech',
                ],
                onChanged: (val) => setState(() => selectedGroup = val),
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat['name'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategory = isSelected ? null : cat['name'];
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkBorderInput
                                    : AppColors.borderFilterIcon),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat['icon'],
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat['name'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(eventProvider.notifier).clearFilters();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorderInput
                                : AppColors.borderCommunityCard,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Clear Filter',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(eventProvider.notifier)
                              .applyFilters(
                                city: selectedCity,
                                state: selectedState,
                                group: selectedGroup,
                                category: selectedCategory,
                              );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Apply Filter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownLabel(String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorderInput
              : AppColors.borderFilterIcon,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              color: AppColors.textCardSubtitle,
              fontSize: 14,
            ),
          ),
          isExpanded: true,
          focusColor: Colors.transparent,
          dropdownColor: isDark ? AppColors.darkSurface : AppColors.background,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.onSurface,
          ),
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
