import 'package:event_management_system/core/utils/json_utils.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String city;
  final String state;
  final String category;
  final String group;
  final String imageUrl;
  final bool isFavorite;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.city,
    required this.state,
    required this.category,
    required this.group,
    required this.imageUrl,
    this.isFavorite = false,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    String? city,
    String? state,
    String? category,
    String? group,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      category: category ?? this.category,
      group: group ?? this.group,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Handles Firestore docs, REST payloads, and mock data.
  ///
  /// Accepted shapes:
  /// - id from `id` or `_id` (Firestore doc ID is passed by the repository)
  /// - dateTime from Timestamp, ISO string, or millis
  /// - isFavorite is user-specific; default false if absent
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: parseString(json['id'] ?? json['_id']),
      title: parseString(json['title']),
      description: parseString(json['description']),
      dateTime: parseDateTime(json['dateTime']) ?? DateTime.now(),
      location: parseString(json['location']),
      city: parseString(json['city']),
      state: parseString(json['state']),
      category: parseString(json['category']),
      group: parseString(json['group'] ?? json['groupId']),
      imageUrl: parseString(json['imageUrl']),
      isFavorite: parseBool(json['isFavorite']),
    );
  }

  /// Do NOT include `id`, `createdAt`, `updatedAt`, or `isFavorite` when
  /// creating via the backend — those are set server-side.
  /// This toJson is used for local persistence and for update payloads.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': serializeDateTime(dateTime),
      'location': location,
      'city': city,
      'state': state,
      'category': category,
      'group': group,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }
}
