import 'package:event_management_system/core/utils/json_utils.dart';

class NotificationModel {
  final String id;
  final String text;
  final String time; // display string ("4:00 PM", "Now")
  final String? imageUrl;
  final bool isUnread;
  final DateTime? createdAt; // real timestamp for sorting; optional

  NotificationModel({
    required this.id,
    required this.text,
    required this.time,
    this.imageUrl,
    this.isUnread = false,
    this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? text,
    String? time,
    String? imageUrl,
    bool? isUnread,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      isUnread: isUnread ?? this.isUnread,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: parseString(json['id'] ?? json['_id']),
      text: parseString(json['text']),
      time: parseString(json['time']),
      imageUrl: json['imageUrl'] as String?,
      isUnread: parseBool(json['isUnread']),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'time': time,
      'imageUrl': imageUrl,
      'isUnread': isUnread,
      'createdAt': serializeDateTime(createdAt),
    };
  }
}
