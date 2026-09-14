import 'package:event_management_system/features/community/models/group_profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_management_system/app/constants/app_assets.dart';

class GroupProfileNotifier extends StateNotifier<GroupProfileState> {
  GroupProfileNotifier()
    : super(
        GroupProfileState(
          groupId: 'Tech Group',
          name: 'Tech Group',
          description: 'Official Flutter & Cross-Platform Mobile Application Development Community.',
          imageUrl: AppAssets.businessGroup,
          memberCount: 1420,
          isJoined: false,
        ),
      );

  void toggleJoinGroup() {
    final nextJoined = !state.isJoined;
    state = state.copyWith(
      isJoined: nextJoined,
      memberCount: nextJoined ? state.memberCount + 1 : state.memberCount - 1,
    );
  }

  void toggleNotifications() {
    state = state.copyWith(isMuted: !state.isMuted);
  }
}

final groupProfileProvider =
    StateNotifierProvider<GroupProfileNotifier, GroupProfileState>((ref) {
      return GroupProfileNotifier();
    });
