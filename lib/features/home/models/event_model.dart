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
}
