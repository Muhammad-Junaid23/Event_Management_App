// ---------------------------------------------------------------------------
// MODELS
// ---------------------------------------------------------------------------
class PollOption {
  final String id;
  final String text;
  final int votes;

  PollOption({required this.id, required this.text, this.votes = 0});

  PollOption copyWith({String? id, String? text, int? votes}) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      votes: votes ?? this.votes,
    );
  }
}

class PollModel {
  final String id;
  final String question;
  final List<PollOption> options;
  final String? userVotedOptionId;

  PollModel({
    required this.id,
    required this.question,
    required this.options,
    this.userVotedOptionId,
  });

  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.votes);

  PollModel copyWith({
    String? id,
    String? question,
    List<PollOption>? options,
    String? userVotedOptionId,
  }) {
    return PollModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      userVotedOptionId: userVotedOptionId ?? this.userVotedOptionId,
    );
  }
}
