import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/services/storage_service.dart';
import 'package:event_management_system/features/auth/providers/auth_provider.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._storage) : super(_loadInitial(_storage));

  final StorageService _storage;

  static ThemeMode _loadInitial(StorageService storage) {
    switch (storage.getThemeMode()) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _storage.saveThemeMode(mode.name);
  }

  void toggleTheme(bool isCurrentlyDark) {
    setTheme(isCurrentlyDark ? ThemeMode.light : ThemeMode.dark);
  }

  void setSystemTheme() {
    setTheme(ThemeMode.system);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref.watch(storageServiceProvider));
});
