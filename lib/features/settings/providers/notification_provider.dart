import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/repositories/notification_repository.dart';
import 'package:event_management_system/features/auth/providers/auth_provider.dart';
import 'package:event_management_system/features/settings/models/notification_model.dart';

class NotificationNotifier
    extends AutoDisposeAsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    final uid = ref.watch(currentUidProvider);
    if (uid == null) {
      // Not signed in → empty list, not an error.
      return const [];
    }

    final repo = ref.watch(notificationRepositoryProvider);
    final stream = repo.watch(uid);

    // Riverpod 2.x doesn't expose ref.mounted. Track disposal ourselves.
    var disposed = false;
    ref.onDispose(() => disposed = true);

    final sub = stream.listen(
      (items) {
        if (!disposed) state = AsyncData(items);
      },
      onError: (e, st) {
        if (!disposed) state = AsyncError(e, st);
      },
    );
    ref.onDispose(sub.cancel);

    // Fulfill the build() contract with the first emission.
    return stream.first;
  }

  Future<void> markAsRead(String id) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    // Optimistic update so the UI reacts instantly.
    final previous = state.value ?? [];
    state = AsyncData([
      for (final n in previous)
        if (n.id == id) n.copyWith(isUnread: false) else n,
    ]);

    try {
      await ref.read(notificationRepositoryProvider).markAsRead(uid, id);
      // The stream will emit the truth shortly; no further action needed.
    } catch (e) {
      // Roll back on failure.
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final previous = state.value ?? [];
    state = AsyncData([for (final n in previous) n.copyWith(isUnread: false)]);
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead(uid);
    } catch (e) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final notificationProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationNotifier,
      List<NotificationModel>
    >(NotificationNotifier.new);
