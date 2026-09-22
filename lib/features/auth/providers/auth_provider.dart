import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:event_management_system/core/repositories/auth_repository.dart';
import 'package:event_management_system/core/repositories/user_repository.dart';
import 'package:event_management_system/core/services/storage_service.dart';

// -----------------------------------------------------------------------------
// SharedPreferences + StorageService (unchanged location — main.dart imports
// sharedPreferencesProvider from this file)
// -----------------------------------------------------------------------------
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main.dart');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(sharedPreferencesProvider));
});

// -----------------------------------------------------------------------------
// Auth stream + uid (used by other providers in later phases)
// -----------------------------------------------------------------------------
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Current Firebase uid, or null if signed out.
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authRepositoryProvider).currentUid;
});

// -----------------------------------------------------------------------------
// Auth state
// -----------------------------------------------------------------------------
class AuthState {
  final bool isFirstTime;
  final bool isLoggedIn;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.isFirstTime,
    required this.isLoggedIn,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isFirstTime,
    bool? isLoggedIn,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isFirstTime: isFirstTime ?? this.isFirstTime,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// -----------------------------------------------------------------------------
// Notifier
// -----------------------------------------------------------------------------
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepo, this._userRepo, this._storage)
    : super(
        AuthState(
          isFirstTime: _storage.isFirstTime(),
          // FirebaseAuth persists its own session; currentUser is the source
          // of truth. No SharedPreferences token needed anymore.
          isLoggedIn: _authRepo.isLoggedIn,
        ),
      );

  final AuthRepository _authRepo;
  final UserRepository _userRepo;
  final StorageService _storage;

  Future<void> completeOnboarding() async {
    await _storage.setFirstTimeCompleted();
    state = state.copyWith(isFirstTime: false);
  }

  Future<void> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final uid = await _authRepo.login(email: email, password: password);
      // Firestore hiccup shouldn't block auth. Log it, keep going.
      try {
        await _userRepo.createIfMissing(
          uid: uid,
          name: _authRepo.currentFirebaseUser?.displayName ?? '',
          email: email.trim(),
        );
      } catch (e) {
        debugPrint('createIfMissing failed (non-fatal): $e');
      }
      state = state.copyWith(isLoading: false, isLoggedIn: true);
    } catch (e) {
      final msg = _friendlyAuthError(e);
      state = state.copyWith(isLoading: false, errorMessage: msg);
      throw Exception(msg);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final uid = await _authRepo.signUp(
        name: name,
        email: email,
        password: password,
      );
      try {
        await _userRepo.createIfMissing(
          uid: uid,
          name: name,
          email: email.trim(),
        );
      } catch (e) {
        debugPrint('createIfMissing failed (non-fatal): $e');
      }
      state = state.copyWith(isLoading: false, isLoggedIn: true);
    } catch (e) {
      final msg = _friendlyAuthError(e);
      state = state.copyWith(isLoading: false, errorMessage: msg);
      throw Exception(msg);
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final uid = await _authRepo.signInWithGoogle();
      try {
        await _userRepo.createIfMissing(
          uid: uid,
          name: _authRepo.currentFirebaseUser?.displayName ?? '',
          email: _authRepo.currentFirebaseUser?.email ?? '',
        );
      } catch (e) {
        debugPrint('createIfMissing failed (non-fatal): $e');
      }
      state = state.copyWith(isLoading: false, isLoggedIn: true);
    } catch (e) {
      final msg = _friendlyAuthError(e);
      state = state.copyWith(isLoading: false, errorMessage: msg);
      throw Exception(msg);
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    state = state.copyWith(isLoggedIn: false, clearError: true);
  }
}

// -----------------------------------------------------------------------------
// Friendly error messages — Firebase codes are ugly for end users.
// -----------------------------------------------------------------------------
String _friendlyAuthError(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'That email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }
  if (e is UnsupportedError) {
    return e.message ?? 'Google sign-in is not available yet.';
  }
  return e.toString().replaceAll('Exception: ', '');
}

// -----------------------------------------------------------------------------
// Provider
// -----------------------------------------------------------------------------
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(userRepositoryProvider),
    ref.watch(storageServiceProvider),
  );
});
