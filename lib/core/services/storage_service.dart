import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _firstTimeKey = 'is_first_time';
  static const String _authTokenKey = 'auth_token';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  bool isFirstTime() {
    return _prefs.getBool(_firstTimeKey) ?? true;
  }

  Future<void> setFirstTimeCompleted() async {
    await _prefs.setBool(_firstTimeKey, false);
  }

  String? getToken() {
    return _prefs.getString(_authTokenKey);
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_authTokenKey, token);
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_authTokenKey);
  }
}
