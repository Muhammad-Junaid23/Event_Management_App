class NotificationModel {
  final String id;
  final String text;
  final String time;
  final String? imageUrl;
  final bool isUnread;

  NotificationModel({
    required this.id,
    required this.text,
    required this.time,
    this.imageUrl,
    this.isUnread = false,
  });

  NotificationModel copyWith({
    String? id,
    String? text,
    String? time,
    String? imageUrl,
    bool? isUnread,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}
