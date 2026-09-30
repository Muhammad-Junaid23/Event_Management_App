import 'package:event_management_system/core/repositories/auth_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/repositories/user_repository.dart';

/// Top-level function to handle background messages.
/// This must be a top-level function (not a class method) and annotated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to perform background tasks, do them here.
  // For web, this runs in the service worker (JS), not Dart.
  if (!kIsWeb) {
    debugPrint('Handling a background message: ${message.messageId}');
  }
}

class PushNotificationService {
  PushNotificationService(this._userRepository, this._auth);

  final UserRepository _userRepository;
  final AuthRepository _auth;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Set the background message handler (mobile only).
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }

    // 2. Request permission.
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
      return; // Don't proceed if permission isn't granted.
    }

    // 3. Get the FCM token for this device.
    //    On web, you'll need a VAPID key from Firebase Console >
    //    Project Settings > Cloud Messaging > Web Push certificates.
    final token = await _messaging.getToken(
      vapidKey: 'BAQpa76C0XjWgIFplmCD6_XBOgaxX6c_f79YCwYUmIvfodUF3DyEhFP5eNVRzDmoibK5AzKlCA0OHdHSESLlnig',
    );
    if (token != null) {
      debugPrint('FCM Token: $token');
      await _saveTokenToFirestore(token);
    }

    // 4. Listen for token refreshes.
    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final uid = _auth.currentUid;
    if (uid == null) return;

    try {
      // Store the token on the user's document.
      await _userRepository.updateFcmToken(uid, token);
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return PushNotificationService(
    ref.watch(userRepositoryProvider),
    ref.watch(authRepositoryProvider),
  );
});
