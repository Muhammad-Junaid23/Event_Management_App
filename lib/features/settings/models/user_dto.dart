class UpdateProfileRequest {
  final String? name;
  final String? localImagePath;

  const UpdateProfileRequest({this.name, this.localImagePath});

  Map<String, dynamic> toJson({String? imageUrl}) {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (imageUrl != null) map['photoUrl'] = imageUrl;
    return map;
  }
}
