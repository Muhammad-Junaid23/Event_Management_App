import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/providers/firebase_providers.dart';
import 'package:event_management_system/features/auth/domain/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  User? get currentFirebaseUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;
  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<String> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(name.trim());

    // Send verification email. Non-blocking — signup succeeds even if this
    // fails (e.g. transient email service error).
    try {
      await cred.user?.sendEmailVerification();
    } catch (_) {
      // Swallow — user can resend from the banner.
    }

    return cred.user!.uid;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!.uid;
  }

  /// Requires google_sign_in to be added later. Placeholder for now.
  Future<String> signInWithGoogle() async {
    if (kIsWeb) {
      // On web, use Firebase's own popup flow. google_sign_in package on web
      // also works but has quirks with the sign-out state; popup is simpler.
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      final cred = await _auth.signInWithPopup(provider);
      final user = cred.user;
      if (user == null) {
        throw StateError('Google sign-in cancelled.');
      }
      return user.uid;
    }

    // Mobile / desktop
    final googleSignIn = GoogleSignIn(scopes: const ['email', 'profile']);
    // Ensure any stale session from a previous login is cleared.
    await googleSignIn.signOut();

    final account = await googleSignIn.signIn();
    if (account == null) {
      throw StateError('Google sign-in cancelled.');
    }

    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user;
    if (user == null) {
      throw StateError('Google sign-in failed.');
    }
    return user.uid;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() => _auth.signOut();

  Future<UserModel> buildUserModelFromCurrent() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user');
    }
    return UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      profileImagePath: user.photoURL ?? '',
    );
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in.');
    await user.sendEmailVerification();
  }

  Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Emits whenever the user object changes (e.g. emailVerified flips).
  Stream<bool> emailVerifiedChanges() {
    return _auth.userChanges().map((u) => u?.emailVerified ?? false);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});
