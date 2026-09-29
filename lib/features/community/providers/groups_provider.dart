import 'package:event_management_system/core/services/storage_service.dart';
import 'package:event_management_system/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/repositories/group_repository.dart';
import 'package:event_management_system/features/community/models/group_profile_model.dart';

/// All groups in the app, streamed from Firestore.
final allGroupsProvider = StreamProvider<List<GroupProfileState>>((ref) {
  return ref.watch(groupRepositoryProvider).watchAll();
});

/// Which group the Community tab is currently showing.
/// Defaults to null; UI sets it to the first group once loaded.
class SelectedGroupNotifier extends StateNotifier<String?> {
  SelectedGroupNotifier(this._storage) : super(_storage.getSelectedGroupId());

  final StorageService _storage;

  Future<void> select(String groupId) async {
    state = groupId;
    await _storage.saveSelectedGroupId(groupId);
  }
}

final selectedGroupProvider =
    StateNotifierProvider<SelectedGroupNotifier, String?>((ref) {
      return SelectedGroupNotifier(ref.watch(storageServiceProvider));
    });

/// The currently selected group object (or null while loading).
final currentGroupProvider = Provider<GroupProfileState?>((ref) {
  final selectedId = ref.watch(selectedGroupProvider);
  final groupsAsync = ref.watch(allGroupsProvider);
  final groups = groupsAsync.value ?? const <GroupProfileState>[];
  if (groups.isEmpty) return null;
  if (selectedId == null) return groups.first;
  return groups.firstWhere(
    (g) => g.groupId == selectedId,
    orElse: () => groups.first,
  );
});
