import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_management_system/features/community/models/community_poll_model.dart';

class CommunityPollsNotifier
    extends StateNotifier<AsyncValue<List<PollModel>>> {
  CommunityPollsNotifier() : super(const AsyncValue.loading()) {
    fetchPolls();
  }

  Future<void> fetchPolls() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final mockPolls = [
        PollModel(
          id: 'poll_1',
          question: 'Which framework feature are you most excited for in 2026?',
          options: [
            PollOption(
              id: 'opt_1',
              text: 'Impeller Engine Enhancements',
              votes: 42,
            ),
            PollOption(id: 'opt_2', text: 'Wasm Web Performance', votes: 28),
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

    state = AsyncValue.data(
      currentPolls.map((poll) {
        if (poll.id != pollId) return poll;
        if (poll.userVotedOptionId == optionId) return poll;

        final updatedOptions = poll.options.map((opt) {
          if (opt.id == optionId) {
            return opt.copyWith(votes: opt.votes + 1);
          } else if (opt.id == poll.userVotedOptionId) {
            return opt.copyWith(votes: (opt.votes - 1).clamp(0, 999999));
          }
          return opt;
        }).toList();

        return poll.copyWith(
          options: updatedOptions,
          userVotedOptionId: optionId,
        );
      }).toList(),
    );
  }
}

final communityPollsProvider =
    StateNotifierProvider<CommunityPollsNotifier, AsyncValue<List<PollModel>>>(
      (ref) => CommunityPollsNotifier(),
    );
