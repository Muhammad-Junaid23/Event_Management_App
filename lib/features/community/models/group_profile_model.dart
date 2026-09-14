import 'package:event_management_system/features/home/models/event_model.dart';

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
}
