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
  // --- MOCKED LOGIN METHOD FOR DEMO ---
  Future<void> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    // 1. Simulate network delay (1.2 seconds)
    await Future.delayed(const Duration(milliseconds: 1200));

    // 2. Demo validation logic
    if (email.trim().toLowerCase() == 'admin@gmail.com' &&
        password == '123456') {
      const mockToken = 'demo_jwt_token_123456789';

      // Save dummy token and update isLoggedIn state
      await login(mockToken);
    } else {
      throw Exception('Invalid credentials. Use admin@gmail.com / 123456');
    }

    /* 
    // REAL API IMPLEMENTATION (Uncomment when backend is ready):
    final apiService = ref.read(authApiServiceProvider);
    final token = await apiService.login(email: email, password: password);
    await login(token);
    */
  }

  // --- MOCKED GOOGLE LOGIN FOR DEMO ---
  Future<void> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    const mockToken = 'google_demo_jwt_token_987654321';
    await login(mockToken);
  }

  // --- MOCKED SIGNUP METHOD FOR DEMO ---
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // 1. Simulate network delay (1.2 seconds)
    await Future.delayed(const Duration(milliseconds: 1200));

    // 2. Save dummy token and log in directly upon registration
    const mockToken = 'demo_signup_jwt_token_456789';
    await login(mockToken);

    /* 
    // REAL API IMPLEMENTATION (Uncomment when backend is ready):
    final apiService = ref.read(authApiServiceProvider);
    final token = await apiService.signUp(name: name, email: email, password: password);
    await login(token);
    */
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
