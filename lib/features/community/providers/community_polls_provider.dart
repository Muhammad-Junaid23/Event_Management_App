import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/repositories/poll_repository.dart';
import 'package:event_management_system/features/auth/providers/auth_provider.dart';
import 'package:event_management_system/features/community/models/community_poll_model.dart';
import 'package:event_management_system/features/community/models/poll_dto.dart';

// -----------------------------------------------------------------------------
// Raw streams
// -----------------------------------------------------------------------------
final _pollsStreamProvider = StreamProvider.autoDispose<List<PollModel>>((ref) {
  return ref.watch(pollRepositoryProvider).watchAll();
});

final _userPollVotesProvider = StreamProvider.autoDispose<Map<String, String>>((
  ref,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const {});
  return ref.watch(pollRepositoryProvider).watchUserVotes(uid);
});

// -----------------------------------------------------------------------------
// Merged provider — polls + user's votes → PollModel with userVotedOptionId set
// -----------------------------------------------------------------------------
List<PollModel> _merge(List<PollModel> polls, Map<String, String> votes) {
  if (votes.isEmpty) return polls;
  return polls.map((poll) {
    final votedOptionId = votes[poll.id];
    if (votedOptionId == null) return poll;
    return poll.copyWith(userVotedOptionId: votedOptionId);
  }).toList();
}

final communityPollsProvider = Provider.autoDispose<AsyncValue<List<PollModel>>>(
  (ref) {
    final pollsAsync = ref.watch(_pollsStreamProvider);
    final votesAsync = ref.watch(_userPollVotesProvider);

    // If polls errored, show that. If polls loading, show loading.
    if (pollsAsync.hasError) {
      return AsyncValue.error(pollsAsync.error!, pollsAsync.stackTrace!);
    }
    if (pollsAsync.isLoading) return const AsyncValue.loading();

    final polls = pollsAsync.value ?? const <PollModel>[];

    // Votes are secondary — if they're still loading, show polls without merge.
    final votes = votesAsync.value ?? const <String, String>{};
    return AsyncValue.data(_merge(polls, votes));
  },
);

// -----------------------------------------------------------------------------
// Actions (create, vote)
// -----------------------------------------------------------------------------
class CommunityPollsActions {
  CommunityPollsActions(this._ref);

  final Ref _ref;

  Future<void> create(CreatePollRequest req, {String? imageUrl}) async {
    await _ref.read(pollRepositoryProvider).create(req, imageUrl: imageUrl);
  }

  Future<void> delete(String pollId) async {
    await _ref.read(pollRepositoryProvider).delete(pollId);
  }

  Future<void> vote(String pollId, String optionId) async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) {
      throw StateError('Sign in required to vote.');
    }
    await _ref
        .read(pollRepositoryProvider)
        .vote(
          uid: uid,
          req: VoteRequest(pollId: pollId, optionId: optionId),
        );
  }
}

final communityPollsActionsProvider =
    Provider.autoDispose<CommunityPollsActions>((ref) {
      return CommunityPollsActions(ref);
    });
