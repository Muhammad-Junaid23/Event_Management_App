import 'package:event_management_system/core/services/auth_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_management_system/core/services/storage_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main.dart');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

class AuthState {
  final bool isFirstTime;
  final bool isLoggedIn;

  const AuthState({required this.isFirstTime, required this.isLoggedIn});
}

class AuthNotifier extends Notifier<AuthState> {
  late final StorageService _storageService;

  @override
  AuthState build() {
    _storageService = ref.watch(storageServiceProvider);

    final isFirstTime = _storageService.isFirstTime();
    final token = _storageService.getToken();

    return AuthState(
      isFirstTime: isFirstTime,
      isLoggedIn: token != null && token.isNotEmpty,
    );
  }

  Future<void> completeOnboarding() async {
    await _storageService.setFirstTimeCompleted();
    state = AuthState(isFirstTime: false, isLoggedIn: state.isLoggedIn);
  }

  Future<void> login(String token) async {
    await _storageService.saveToken(token);
    state = AuthState(isFirstTime: false, isLoggedIn: true);
  }

  Future<void> logout() async {
    await _storageService.clearAuth();
    state = AuthState(isFirstTime: state.isFirstTime, isLoggedIn: false);
  }

  // Add this method inside your AuthNotifier class:
  Future<void> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    final apiService = ref.read(authApiServiceProvider);
    final token = await apiService.login(email: email, password: password);

    // Save token locally and update state
    await login(token);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
