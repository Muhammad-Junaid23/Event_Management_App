import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/app/constants/app_assets.dart';

import 'package:event_management_system/features/community/models/group_profile_model.dart';

class GroupProfileNotifier extends StateNotifier<GroupProfileState> {
  GroupProfileNotifier()
    : super(
        GroupProfileState(
          groupId: 'grp_1',
          name: 'Business group',
          description: 'Lorem ipsum dolor sit amet consectetur. Cras elit volutpat morbi mauris tincidunt lacus.',
          imageUrl: AppAssets.businessGroup,
          memberCount: 14000,
          isJoined: false,
          isMuted: false,
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
    StateNotifierProvider<GroupProfileNotifier, GroupProfileState>(
      (ref) => GroupProfileNotifier(),
    );
