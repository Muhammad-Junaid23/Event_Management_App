import 'package:event_management_system/features/home/models/event_model.dart';
import 'package:event_management_system/core/utils/json_utils.dart';

class GroupProfileState {
  final String groupId;
  final String name;
  final String description;
  final String imageUrl;
  final int memberCount;
  final bool isJoined;
  final bool isMuted;
  final List<EventModel> events;
  final bool isLoading;

  GroupProfileState({
    required this.groupId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.memberCount,
    this.isJoined = false,
    this.isMuted = false,
    this.events = const [],
    this.isLoading = false,
  });

  GroupProfileState copyWith({
    String? groupId,
    String? name,
    String? description,
    String? imageUrl,
    int? memberCount,
    bool? isJoined,
    bool? isMuted,
    List<EventModel>? events,
    bool? isLoading,
  }) {
    return GroupProfileState(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
      isMuted: isMuted ?? this.isMuted,
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory GroupProfileState.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'];
    return GroupProfileState(
      groupId: parseString(json['groupId'] ?? json['id']),
      name: parseString(json['name']),
      description: parseString(json['description']),
      imageUrl: parseString(json['imageUrl']),
      memberCount: parseInt(json['memberCount']),
      isJoined: parseBool(json['isJoined']),
      isMuted: parseBool(json['isMuted']),
      events: rawEvents is List
          ? rawEvents
                .whereType<Map>()
                .map((e) => EventModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      isLoading: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'memberCount': memberCount,
      'isJoined': isJoined,
      'isMuted': isMuted,
      'events': events.map((e) => e.toJson()).toList(),
    };
  }
}
