import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _firstTimeKey = 'is_first_time';
  static const String _themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------
  bool isFirstTime() => _prefs.getBool(_firstTimeKey) ?? true;

  Future<void> setFirstTimeCompleted() async {
    await _prefs.setBool(_firstTimeKey, false);
  }

  // ---------------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------------
  String? getThemeMode() => _prefs.getString(_themeModeKey);

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }
}
