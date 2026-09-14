// import 'package:event_management_system/features/community/models/community_poll_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // ---------------------------------------------------------------------------
// // STATE & NOTIFIER
// // ---------------------------------------------------------------------------
// class CommunityState {
//   final List<PollModel> polls;

//   CommunityState({required this.polls});

//   CommunityState copyWith({List<PollModel>? polls}) {
//     return CommunityState(polls: polls ?? this.polls);
//   }
// }

// class CommunityNotifier extends StateNotifier<CommunityState> {
//   CommunityNotifier()
//     : super(
//         CommunityState(
//           polls: [
//             PollModel(
//               id: 'poll_1',
//               question:
//                   'Which framework feature are you most excited for in 2026?',
//               options: [
//                 PollOption(
//                   id: 'opt_1',
//                   text: 'Impeller Engine Enhancements',
//                   votes: 42,
//                 ),
//                 PollOption(
//                   id: 'opt_2',
//                   text: 'Wasm Web Performance',
//                   votes: 28,
//                 ),
//                 PollOption(
//                   id: 'opt_3',
//                   text: 'Enhanced DevTools Suite',
//                   votes: 15,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );

//   /// Handles voting/changing vote on a community poll
//   void vote(String pollId, String optionId) {
//     final updatedPolls = state.polls.map((poll) {
//       if (poll.id != pollId) return poll;

//       // If already voted for the same option, do nothing
//       if (poll.userVotedOptionId == optionId) return poll;

//       final updatedOptions = poll.options.map((opt) {
//         if (opt.id == optionId) {
//           return opt.copyWith(votes: opt.votes + 1);
//         } else if (opt.id == poll.userVotedOptionId) {
//           return opt.copyWith(votes: (opt.votes - 1).clamp(0, 999999));
//         }
//         return opt;
//       }).toList();

//       return poll.copyWith(
//         options: updatedOptions,
//         userVotedOptionId: optionId,
//       );
//     }).toList();

//     state = state.copyWith(polls: updatedPolls);
//   }
// }

// final communityProvider =
//     StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
//       return CommunityNotifier();
//     });

import 'package:event_management_system/features/community/models/community_poll_model.dart';
import 'package:event_management_system/features/community/models/group_profile_model.dart';
import 'package:event_management_system/features/home/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_management_system/app/constants/app_assets.dart';

// ---------------------------------------------------------------------------
// COMMUNITY POLLS PROVIDER
// ---------------------------------------------------------------------------
class CommunityPollsNotifier
    extends StateNotifier<AsyncValue<List<PollModel>>> {
  CommunityPollsNotifier() : super(const AsyncValue.loading()) {
    fetchPolls();
  }

  Future<void> fetchPolls() async {
    state = const AsyncValue.loading();
    try {
      // Mock API delay for backend readiness
      await Future.delayed(const Duration(milliseconds: 500));

      final mockPolls = [
        PollModel(
          id: 'poll_1',
          question: 'Made in Melanin! Black History Month Social',
          options: [
            PollOption(id: 'opt_1', text: 'In-Person Event', votes: 120),
            PollOption(id: 'opt_2', text: 'Virtual Event', votes: 85),
          ],
        ),
      ];
      state = AsyncValue.data(mockPolls);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> voteOption(String pollId, String optionId) async {
    final currentPolls = state.value;
    if (currentPolls == null) return;

    // Optimistic UI update
    state = AsyncValue.data(
      currentPolls.map((poll) {
        if (poll.id == pollId) {
          final updatedOptions = poll.options.map((opt) {
            if (opt.id == optionId) {
              return opt.copyWith(votes: opt.votes + 1);
            }
            return opt;
          }).toList();

          return poll.copyWith(
            options: updatedOptions,
            userVotedOptionId: optionId,
          );
        }
        return poll;
      }).toList(),
    );

    // TODO: Connect API call here -> await apiService.vote(pollId, optionId);
  }
}

final communityPollsProvider =
    StateNotifierProvider<CommunityPollsNotifier, AsyncValue<List<PollModel>>>(
      (ref) => CommunityPollsNotifier(),
    );

// ---------------------------------------------------------------------------
// GROUP PROFILE PROVIDER
// ---------------------------------------------------------------------------
class GroupProfileNotifier extends StateNotifier<GroupProfileState> {
  GroupProfileNotifier()
    : super(
        GroupProfileState(
          groupId: 'grp_1',
          name: 'Business group',
          description: 'Lorem ipsum dolor sit amet consectetur. Cras elit volutpat morbi mauris tincidunt lacus.',
          imageUrl: AppAssets.businessGroup,
          memberCount: 14000,
        ),
      ) {
    loadGroupDetails();
  }

  Future<void> loadGroupDetails() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 400));

    final List<EventModel> groupEvents = [
      EventModel(
        id: 'evt_1',
        title: 'Made in Melanin! Black History Month Social.....',
        description: 'Join us for our monthly group social gathering!',
        dateTime: DateTime(2025, 10, 28, 18, 0),
        location: '1901 Thornridge Cir. Shiloh',
        city: 'Shiloh',
        state: 'Hawaii',
        category: 'Social',
        group: 'Business group',
        imageUrl: AppAssets.businessGroup,
        isFavorite: false,
      ),
    ];

    state = state.copyWith(events: groupEvents, isLoading: false);
  }

  void toggleJoinGroup() {
    final newJoinState = !state.isJoined;
    final updatedCount = newJoinState
        ? state.memberCount + 1
        : state.memberCount - 1;
    state = state.copyWith(isJoined: newJoinState, memberCount: updatedCount);
    // TODO: Connect API endpoint -> await repository.toggleJoin(state.groupId);
  }

  void toggleMuteGroup() {
    state = state.copyWith(isMuted: !state.isMuted);
    // TODO: Connect API endpoint -> await repository.toggleMute(state.groupId);
  }
}

final groupProfileProvider =
    StateNotifierProvider<GroupProfileNotifier, GroupProfileState>(
      (ref) => GroupProfileNotifier(),
    );
