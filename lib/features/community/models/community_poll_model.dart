import 'package:event_management_system/core/utils/json_utils.dart';

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

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: parseString(json['id'] ?? json['_id']),
      text: parseString(json['text']),
      votes: parseInt(json['votes']),
    );
  }

  /// Safe for backend create payloads (id/votes are server-managed when new).
  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'votes': votes};
  }
}

class PollModel {
  final String id;
  final String question;
  final List<PollOption> options;
  final String? userVotedOptionId;
  final String? imageUrl;

  PollModel({
    required this.id,
    required this.question,
    required this.options,
    this.userVotedOptionId,
    this.imageUrl,
  });

  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.votes);

  PollModel copyWith({
    String? id,
    String? question,
    List<PollOption>? options,
    String? userVotedOptionId,
    String? imageUrl,
    bool clearUserVote = false,
  }) {
    return PollModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      userVotedOptionId: clearUserVote
          ? null
          : (userVotedOptionId ?? this.userVotedOptionId),
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = rawOptions is List
        ? rawOptions
              .whereType<Map>()
              .map((e) => PollOption.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <PollOption>[];

    return PollModel(
      id: parseString(json['id'] ?? json['_id']),
      question: parseString(json['question']),
      options: options,
      userVotedOptionId: json['userVotedOptionId'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((o) => o.toJson()).toList(),
      'userVotedOptionId': userVotedOptionId,
      'imageUrl': imageUrl,
    };
  }
}
