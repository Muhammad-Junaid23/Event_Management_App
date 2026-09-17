class UserModel {
  final String id;
  final String name;
  final String email;
  final String profileImagePath;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImagePath,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImagePath,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
