// lib/features/settings/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  // Start with system theme as default
  ThemeNotifier() : super(ThemeMode.system);

  /// Toggle explicitly between Light and Dark
  void toggleTheme(bool isCurrentlyDark) {
    state = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
  }

  /// Reset back to device system setting
  void setSystemTheme() {
    state = ThemeMode.system;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
