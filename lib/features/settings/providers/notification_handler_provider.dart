import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:event_management_system/app/config/routes.dart';
import 'package:event_management_system/core/services/push_notification_service.dart';
import 'package:event_management_system/features/auth/providers/auth_provider.dart';

/// One-time bootstrap for push notifications.
/// - Registers the FCM token when a user signs in.
/// - Wires foreground, background, and terminated-state message listeners.
final notificationHandlerProvider = Provider<void>((ref) {
  // 1. Register FCM token whenever the signed-in user changes.
  ref.listen<String?>(currentUidProvider, (previous, next) {
    if (next != null && previous != next) {
      // Fire and forget. Errors are logged inside the service.
      ref.read(pushNotificationServiceProvider).initialize();
    }
  }, fireImmediately: true);

  // 2. Foreground messages.
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM] Foreground message: ${message.messageId}');
      debugPrint('[FCM] Data: ${message.data}');
    }
    // Optional: show an in-app SnackBar or banner here later.
  });

  // 3. Notification tapped while app was in background.
  FirebaseMessaging.onMessageOpenedApp.listen(_navigateFromMessage);

  // 4. Notification tapped that launched the app from a terminated state.
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      // Defer to the next frame so the router is mounted.
      Future.microtask(() => _navigateFromMessage(message));
    }
  });
});

/// Navigates to `data['route']` if present. Silently no-ops otherwise.
void _navigateFromMessage(RemoteMessage message) {
  final route = message.data['route'] as String?;
  if (route == null || route.isEmpty) return;

  final ctx = AppRoutes.rootNavigatorKey.currentContext;
  if (ctx == null) return;

  GoRouter.of(ctx).go(route);
}
