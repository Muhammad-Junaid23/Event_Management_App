class CreatePollRequest {
  final String question;
  final List<String> options;
  final String groupId;
  final String? localImagePath;

  const CreatePollRequest({
    required this.question,
    required this.options,
    required this.groupId,
    this.localImagePath,
  });

  Map<String, dynamic> toJson({String? imageUrl}) {
    return {
      'question': question,
      'options': options,
      'group': groupId,
      'imageUrl': imageUrl ?? '',
    };
  }
}

class VoteRequest {
  final String pollId;
  final String optionId;

  const VoteRequest({required this.pollId, required this.optionId});

  Map<String, dynamic> toJson() {
    return {'pollId': pollId, 'optionId': optionId};
  }
}
