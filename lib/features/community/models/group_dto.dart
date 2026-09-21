class JoinGroupRequest {
  final String groupId;
  final bool join; // true to join, false to leave

  const JoinGroupRequest({required this.groupId, required this.join});

  Map<String, dynamic> toJson() => {'groupId': groupId, 'join': join};
}

class MuteGroupRequest {
  final String groupId;
  final bool muted;

  const MuteGroupRequest({required this.groupId, required this.muted});

  Map<String, dynamic> toJson() => {'groupId': groupId, 'muted': muted};
}
