import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/features/home/providers/event_provider.dart';

class EventSearchField extends ConsumerStatefulWidget {
  const EventSearchField({super.key});

  @override
  ConsumerState<EventSearchField> createState() => _EventSearchFieldState();
}

class _EventSearchFieldState extends ConsumerState<EventSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasText = _controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.tileBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {});
          ref.read(searchQueryProvider.notifier).set(value);
        },
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Search events by title or location',
          hintStyle: const TextStyle(
            color: AppColors.textCardSubtitle,
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.textCardSubtitle,
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSubtle,
                  ),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                )
              : null,
        ),
      ),
    );
  }
}
