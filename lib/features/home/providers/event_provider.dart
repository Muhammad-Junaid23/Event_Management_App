import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_model.dart';

// ---------------------------------------------------------------------------
// 1. EVENT STATE
// ---------------------------------------------------------------------------
class EventState {
  final List<EventModel> allEvents;
  final String? selectedCity;
  final String? selectedState;
  final String? selectedGroup;
  final String? selectedCategory;
  final DateTime selectedDate;

  EventState({
    required this.allEvents,
    this.selectedCity,
    this.selectedState,
    this.selectedGroup,
    this.selectedCategory,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  /// Returns events filtered by city, state, group, and category.
  List<EventModel> get filteredEvents {
    return allEvents.where((event) {
      final matchesCity = selectedCity == null || event.city == selectedCity;
      final matchesState =
          selectedState == null || event.state == selectedState;
      final matchesGroup =
          selectedGroup == null || event.group == selectedGroup;
      final matchesCategory =
          selectedCategory == null || event.category == selectedCategory;

      return matchesCity && matchesState && matchesGroup && matchesCategory;
    }).toList();
  }

  /// Returns filtered events for a specific calendar date.
  List<EventModel> getEventsForDay(DateTime day) {
    return filteredEvents.where((event) {
      return event.dateTime.year == day.year &&
          event.dateTime.month == day.month &&
          event.dateTime.day == day.day;
    }).toList();
  }

  EventState copyWith({
    List<EventModel>? allEvents,
    String? selectedCity,
    String? selectedState,
    String? selectedGroup,
    String? selectedCategory,
    DateTime? selectedDate,
    bool clearCity = false,
    bool clearState = false,
    bool clearGroup = false,
    bool clearCategory = false,
  }) {
    return EventState(
      allEvents: allEvents ?? this.allEvents,
      selectedCity: clearCity ? null : (selectedCity ?? this.selectedCity),
      selectedState: clearState ? null : (selectedState ?? this.selectedState),
      selectedGroup: clearGroup ? null : (selectedGroup ?? this.selectedGroup),
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

// ---------------------------------------------------------------------------
// 2. EVENT NOTIFIER
// ---------------------------------------------------------------------------
class EventNotifier extends StateNotifier<EventState> {
  EventNotifier()
    : super(
        EventState(
          allEvents: [
            EventModel(
              id: '1',
              title: 'Flutter Tech Summit 2026',
              description:
                  'Explore cross-platform innovations and best practices.',
              dateTime: DateTime.now().add(const Duration(hours: 2)),
              location: '2464 Royal Ln. Mesa, New Jersey',
              city: 'Mesa',
              state: 'New Jersey',
              category: 'Business',
              group: 'Tech Group',
              imageUrl: 'assets/images/featuresCard.png',
              isFavorite: true,
            ),
            EventModel(
              id: '2',
              title: 'Global Business Forum',
              description:
                  'Networking session with industry leaders and investors.',
              dateTime: DateTime.now().add(const Duration(days: 1)),
              location: 'Convention Center, New York',
              city: 'New York',
              state: 'New York',
              category: 'Business',
              group: 'Group A',
              imageUrl: 'assets/images/businessGroup.jpg',
            ),
            EventModel(
              id: '3',
              title: 'Community Marathon',
              description:
                  'Annual community running and health awareness event.',
              dateTime: DateTime.now().add(const Duration(days: 2)),
              location: 'InnovateSpace, Los Angeles',
              city: 'Los Angeles',
              state: 'California',
              category: 'Sports',
              group: 'Group B',
              imageUrl: 'assets/images/featuresCard.png',
            ),
          ],
        ),
      );

  /// Toggle favorite status of an event by ID
  void toggleFavorite(String id) {
    final updatedList = state.allEvents.map((event) {
      if (event.id == id) {
        return event.copyWith(isFavorite: !event.isFavorite);
      }
      return event;
    }).toList();

    state = state.copyWith(allEvents: updatedList);
  }

  /// Update selected calendar day
  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// Apply all filter selections
  void applyFilters({
    String? city,
    String? state,
    String? group,
    String? category,
  }) {
    this.state = EventState(
      allEvents: this.state.allEvents,
      selectedCity: city,
      selectedState: state,
      selectedGroup: group,
      selectedCategory: category,
      selectedDate: this.state.selectedDate,
    );
  }

  /// Reset all filters to null
  void clearFilters() {
    state = EventState(
      allEvents: state.allEvents,
      selectedDate: state.selectedDate,
    );
  }
}

// ---------------------------------------------------------------------------
// 3. PROVIDERS
// ---------------------------------------------------------------------------

/// Main Event State Provider
final eventProvider = StateNotifierProvider<EventNotifier, EventState>((ref) {
  return EventNotifier();
});

/// Direct Provider for Filtered Events List
final filteredEventsProvider = Provider<List<EventModel>>((ref) {
  return ref.watch(eventProvider).filteredEvents;
});

/// Direct Provider for Events on Currently Selected Calendar Day
final selectedDateEventsProvider = Provider<List<EventModel>>((ref) {
  final state = ref.watch(eventProvider);
  return state.getEventsForDay(state.selectedDate);
});
