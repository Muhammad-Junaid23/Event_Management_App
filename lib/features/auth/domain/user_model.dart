import 'package:event_management_system/core/utils/json_utils.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String profileImagePath;
  final String? bio;
  final List<String> favoriteEventIds;
  final List<String> rsvpEventIds;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImagePath,
    this.bio,
    this.favoriteEventIds = const [],
    this.rsvpEventIds = const [],
    this.isAdmin = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImagePath,
    String? bio,
    List<String>? favoriteEventIds,
    List<String>? rsvpEventIds,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      bio: bio ?? this.bio,
      favoriteEventIds: favoriteEventIds ?? this.favoriteEventIds,
      rsvpEventIds: rsvpEventIds ?? this.rsvpEventIds,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawFavs = json['favoriteEventIds'];
    final rawRSVPEvents = json['rsvpEventIds'];
    return UserModel(
      id: parseString(json['id'] ?? json['_id']),
      name: parseString(json['name']),
      email: parseString(json['email']),
      profileImagePath: parseString(
        json['profileImagePath'] ?? json['photoUrl'],
      ),
      bio: json['bio'] as String?,
      favoriteEventIds: rawFavs is List
          ? rawFavs.map((e) => e.toString()).toList()
          : const [],
      rsvpEventIds: rawRSVPEvents is List
          ? rawRSVPEvents.map((e) => e.toString()).toList()
          : const [],
      isAdmin: parseBool(json['isAdmin']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImagePath': profileImagePath,
      'bio': bio,
      'favoriteEventIds': favoriteEventIds,
      'rsvpEventIds': rsvpEventIds,
      'isAdmin': isAdmin,
    };
  }
}
