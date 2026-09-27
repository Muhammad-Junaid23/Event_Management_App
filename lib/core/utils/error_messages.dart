import 'package:firebase_auth/firebase_auth.dart';

/// Converts Firebase exceptions into short, human-readable text.
/// Use this in every `error:` branch of `.when(...)`.
String friendlyError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'That email is already registered.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Sign-in cancelled.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }

  if (error is FirebaseException) {
    switch (error.code) {
      case 'unavailable':
        return 'Cannot reach the server. Check your connection.';
      case 'permission-denied':
        return 'You don\'t have permission to view this.';
      case 'not-found':
        return 'This item no longer exists.';
      case 'deadline-exceeded':
        return 'Request timed out. Try again.';
      case 'unauthenticated':
        return 'Please sign in again.';
      default:
        return error.message ?? 'Something went wrong.';
    }
  }

  final str = error.toString();
  if (str.contains('SocketException') || str.contains('ClientException')) {
    return 'Network error. Check your connection.';
  }

  return 'Something went wrong. Please try again.';
}
