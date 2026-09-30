import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/repositories/auth_repository.dart';

/// Reloads the current Firebase user whenever the app returns to foreground.
/// This is how the app picks up email-verification status changes.
class AppLifecycleReloader extends ConsumerStatefulWidget {
  final Widget child;
  const AppLifecycleReloader({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleReloader> createState() =>
      _AppLifecycleReloaderState();
}

class _AppLifecycleReloaderState extends ConsumerState<AppLifecycleReloader>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(authRepositoryProvider).reloadCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
