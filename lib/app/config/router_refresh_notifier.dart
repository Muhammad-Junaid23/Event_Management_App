import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/features/auth/providers/auth_provider.dart';

/// Bridges Riverpod's authProvider into a Listenable that GoRouter can use
/// as `refreshListenable`.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isLoggedIn != next.isLoggedIn ||
          previous?.isFirstTime != next.isFirstTime) {
        notifyListeners();
      }
    });
  }
}

final routerRefreshNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  return RouterRefreshNotifier(ref);
});
