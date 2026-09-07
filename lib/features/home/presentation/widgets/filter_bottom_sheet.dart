import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedCity;
  String? selectedState;
  String? selectedGroup;
  String selectedCategory = 'Business';

  final List<Map<String, dynamic>> categories = [
    {'name': 'Religious', 'icon': Icons.nightlight_round},
    {'name': 'Business', 'icon': Icons.business},
    {'name': 'Sports', 'icon': Icons.directions_run},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Community', 'icon': Icons.groups},
  ];

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
              // Header
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

              // City Dropdown
              _buildDropdownLabel('City', theme),
              _buildDropdown(
                hint: 'Select City',
                value: selectedCity,
                items: ['New York', 'Mesa', 'Los Angeles'],
                onChanged: (val) => setState(() => selectedCity = val),
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // State Dropdown
              _buildDropdownLabel('State', theme),
              _buildDropdown(
                hint: 'Select State',
                value: selectedState,
                items: ['New Jersey', 'California', 'Texas'],
                onChanged: (val) => setState(() => selectedState = val),
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // Groups Dropdown
              _buildDropdownLabel('Groups', theme),
              _buildDropdown(
                hint: 'Group',
                value: selectedGroup,
                items: ['Group A', 'Group B', 'Tech Group'],
                onChanged: (val) => setState(() => selectedGroup = val),
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // Category Filter Tags
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat['name'];
                  return InkWell(
                    onTap: () => setState(() => selectedCategory = cat['name']),
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

              // Increased Height Action Buttons (Fix 2)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52, // Tall button height matching Figma
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            selectedCity = null;
                            selectedState = null;
                            selectedGroup = null;
                          });
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
                      height: 52, // Tall button height matching Figma
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
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

  // Fixed Dropdown clipping overlay issue (Fix 1)
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
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          isExpanded: true,
          // Disables the default grey rectangular focus overlay completely
          focusColor: Colors.transparent,
          dropdownColor: isDark ? AppColors.darkSurface : AppColors.background,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.onSurface,
          ),
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  e,
                  style: TextStyle(color: theme.colorScheme.onSurface),
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
