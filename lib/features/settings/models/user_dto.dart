class UpdateProfileRequest {
  final String? name;
  final String? imageUrl;

  const UpdateProfileRequest({this.name, this.imageUrl});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (imageUrl != null) map['profileImagePath'] = imageUrl;
    return map;
  }
}
