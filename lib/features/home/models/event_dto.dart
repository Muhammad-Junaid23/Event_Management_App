import 'package:event_management_system/core/utils/json_utils.dart';

/// Fields required to create an event. No id, no isFavorite, no createdAt.
class CreateEventRequest {
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String city;
  final String state;
  final String category;
  final String groupId;
  final String?
  localImagePath; // uploaded by StorageRepository, then replaced with URL

  const CreateEventRequest({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.city,
    required this.state,
    required this.category,
    required this.groupId,
    this.localImagePath,
  });

  Map<String, dynamic> toJson({String? imageUrl}) {
    return {
      'title': title,
      'description': description,
      'dateTime': serializeDateTime(dateTime),
      'location': location,
      'city': city,
      'state': state,
      'category': category,
      'group': groupId,
      'imageUrl': imageUrl ?? '',
    };
  }
}

/// Fields allowed to be updated after creation.
class UpdateEventRequest {
  final String? title;
  final String? description;
  final DateTime? dateTime;
  final String? location;
  final String? city;
  final String? state;
  final String? category;
  final String? groupId;
  final String? imageUrl;

  const UpdateEventRequest({
    this.title,
    this.description,
    this.dateTime,
    this.location,
    this.city,
    this.state,
    this.category,
    this.groupId,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (dateTime != null) map['dateTime'] = serializeDateTime(dateTime);
    if (location != null) map['location'] = location;
    if (city != null) map['city'] = city;
    if (state != null) map['state'] = state;
    if (category != null) map['category'] = category;
    if (groupId != null) map['group'] = groupId;
    if (imageUrl != null) map['imageUrl'] = imageUrl;
    return map;
  }
}
