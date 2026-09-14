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

  //Adding JSON serialization methods
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      category: json['category'] as String,
      group: json['group'] as String,
      imageUrl: json['imageUrl'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
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
