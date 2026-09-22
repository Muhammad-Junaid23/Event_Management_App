import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/repositories/group_repository.dart';
import 'package:event_management_system/features/auth/providers/auth_provider.dart';
import 'package:event_management_system/features/community/models/group_dto.dart';
import 'package:event_management_system/features/community/models/group_profile_model.dart';

class GroupProfileNotifier
    extends AutoDisposeFamilyAsyncNotifier<GroupProfileState, String> {
  @override
  Future<GroupProfileState> build(String groupId) async {
    final repo = ref.watch(groupRepositoryProvider);
    final uid = ref.watch(currentUidProvider);

    final group = await repo.getById(groupId);
    if (group == null) {
      throw StateError('Group not found: $groupId');
    }

    if (uid == null) {
      return group.copyWith(isJoined: false, isMuted: false);
    }

    final membership = await repo.getMembership(uid, groupId);
    return group.copyWith(
      isJoined: membership.joined,
      isMuted: membership.muted,
    );
  }

  Future<void> toggleJoinGroup() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) throw StateError('Not signed in');

    final current = state.value;
    if (current == null) return;

    final nextJoined = !current.isJoined;
    final previous = current;

    // Optimistic: flip the flag immediately for snappy UI.
    state = AsyncData(
      current.copyWith(
        isJoined: nextJoined,
        memberCount: nextJoined
            ? current.memberCount + 1
            : (current.memberCount - 1).clamp(0, 1 << 31),
      ),
    );

    try {
      await ref
          .read(groupRepositoryProvider)
          .join(
            JoinGroupRequest(groupId: current.groupId, join: nextJoined),
            uid,
          );
      // Refetch to sync memberCount with server truth (other users may have
      // joined/left between our read and write).
      ref.invalidateSelf();
    } catch (e) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> toggleNotifications() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) throw StateError('Not signed in');

    final current = state.value;
    if (current == null) return;

    final nextMuted = !current.isMuted;
    final previous = current;

    state = AsyncData(current.copyWith(isMuted: nextMuted));

    try {
      await ref
          .read(groupRepositoryProvider)
          .setMuted(
            MuteGroupRequest(groupId: current.groupId, muted: nextMuted),
            uid,
          );
    } catch (e) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final groupProfileProvider = AsyncNotifierProvider.autoDispose
    .family<GroupProfileNotifier, GroupProfileState, String>(
      GroupProfileNotifier.new,
    );
