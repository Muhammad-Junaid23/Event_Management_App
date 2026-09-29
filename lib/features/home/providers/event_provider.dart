import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/repositories/event_repository.dart';
import 'package:event_management_system/core/repositories/user_repository.dart';
import 'package:event_management_system/features/auth/providers/auth_provider.dart';
import 'package:event_management_system/features/home/models/event_dto.dart';
import 'package:event_management_system/features/home/models/event_model.dart';

// -----------------------------------------------------------------------------
// 1. Filters
// -----------------------------------------------------------------------------
class EventFilters {
  final String? city;
  final String? state;
  final String? group;
  final String? category;

  const EventFilters({this.city, this.state, this.group, this.category});

  bool get isEmpty =>
      city == null && state == null && group == null && category == null;
}

/// Scope lets each screen own an independent filter set.
enum EventFilterScope { home, features }

class EventFiltersNotifier extends StateNotifier<EventFilters> {
  EventFiltersNotifier() : super(const EventFilters());

  void setFilters({
    String? city,
    String? stateValue,
    String? group,
    String? category,
  }) {
    state = EventFilters(
      city: city,
      state: stateValue,
      group: group,
      category: category,
    );
  }

  void clear() => state = const EventFilters();
}

final eventFiltersProvider =
    StateNotifierProvider.family<
      EventFiltersNotifier,
      EventFilters,
      EventFilterScope
    >((ref, scope) {
      return EventFiltersNotifier();
    });

// -----------------------------------------------------------------------------
// Search query (independent of the filter sheet)
// -----------------------------------------------------------------------------
class SearchQueryNotifier extends StateNotifier<String> {
  SearchQueryNotifier() : super('');

  void set(String value) => state = value.trim();

  void clear() => state = '';
}

final searchQueryProvider = StateNotifierProvider<SearchQueryNotifier, String>((
  ref,
) {
  return SearchQueryNotifier();
});

// -----------------------------------------------------------------------------
// 2. Selected calendar date
// -----------------------------------------------------------------------------
class SelectedDateNotifier extends StateNotifier<DateTime> {
  SelectedDateNotifier() : super(DateTime.now());

  void set(DateTime date) => state = date;
}

final selectedDateProvider =
    StateNotifierProvider<SelectedDateNotifier, DateTime>((ref) {
      return SelectedDateNotifier();
    });

// -----------------------------------------------------------------------------
// 3. Raw event stream from Firestore
// -----------------------------------------------------------------------------
final eventsProvider = StreamProvider<List<EventModel>>((ref) {
  return ref.watch(eventRepositoryProvider).watchAll();
});

// -----------------------------------------------------------------------------
// 4. User's favorite event ids (stream)
// -----------------------------------------------------------------------------
final favoriteEventIdsProvider = StreamProvider<List<String>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const <String>[]);
  return ref.watch(userRepositoryProvider).watchFavoriteIds(uid);
});

final rsvpEventIdsProvider = StreamProvider<List<String>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const <String>[]);
  return ref.watch(userRepositoryProvider).watchRsvpIds(uid);
});

// -----------------------------------------------------------------------------
// 5. Events with isFavorite populated from the user's favorites
// -----------------------------------------------------------------------------
final eventsWithFavoriteProvider = Provider<AsyncValue<List<EventModel>>>((
  ref,
) {
  final eventsAsync = ref.watch(eventsProvider);
  final favIdsAsync = ref.watch(favoriteEventIdsProvider);
  final rsvpAsync = ref.watch(rsvpEventIdsProvider);

  if (eventsAsync.hasError) {
    return AsyncValue.error(eventsAsync.error!, eventsAsync.stackTrace!);
  }
  if (eventsAsync.isLoading) return const AsyncValue.loading();

  final events = eventsAsync.value ?? const <EventModel>[];
  final idSet = (favIdsAsync.value ?? const <String>[]).toSet();
  final rsvpIds = (rsvpAsync.value ?? const <String>[]).toSet();

  return AsyncValue.data([
    for (final e in events)
      e.copyWith(
        isFavorite: idSet.contains(e.id),
        isRsvped: rsvpIds.contains(e.id),
      ),
  ]);
});

// -----------------------------------------------------------------------------
// 6. Derived: filtered events
// -----------------------------------------------------------------------------
final filteredEventsProvider =
    Provider.family<AsyncValue<List<EventModel>>, EventFilterScope>((
      ref,
      scope,
    ) {
      final eventsAsync = ref.watch(eventsWithFavoriteProvider);
      final filters = ref.watch(eventFiltersProvider(scope));
      final query = ref.watch(searchQueryProvider).toLowerCase();

      return eventsAsync.whenData((events) {
        return events.where((e) {
          final matchesCity = filters.city == null || e.city == filters.city;
          final matchesState =
              filters.state == null || e.state == filters.state;
          final matchesGroup =
              filters.group == null || e.group == filters.group;
          final matchesCategory =
              filters.category == null || e.category == filters.category;

          final matchesQuery =
              query.isEmpty ||
              e.title.toLowerCase().contains(query) ||
              e.location.toLowerCase().contains(query);

          return matchesCity &&
              matchesState &&
              matchesGroup &&
              matchesCategory &&
              matchesQuery;
        }).toList();
      });
    });

// -----------------------------------------------------------------------------
// 7. Derived: events on the selected day
// -----------------------------------------------------------------------------
final selectedDateEventsProvider = Provider<AsyncValue<List<EventModel>>>((
  ref,
) {
  final filtered = ref.watch(filteredEventsProvider(EventFilterScope.home));
  final date = ref.watch(selectedDateProvider);

  return filtered.whenData(
    (events) => events.where((e) {
      return e.dateTime.year == date.year &&
          e.dateTime.month == date.month &&
          e.dateTime.day == date.day;
    }).toList(),
  );
});

// -----------------------------------------------------------------------------
// 8. Derived: favorites
// -----------------------------------------------------------------------------
final favoriteEventsProvider = Provider<AsyncValue<List<EventModel>>>((ref) {
  return ref
      .watch(eventsWithFavoriteProvider)
      .whenData((events) => events.where((e) => e.isFavorite).toList());
});

// -----------------------------------------------------------------------------
// 9. Actions
// -----------------------------------------------------------------------------
class EventActions {
  EventActions(this._ref);
  final Ref _ref;

  Future<void> create(CreateEventRequest req, {String? imageUrl}) async {
    await _ref.read(eventRepositoryProvider).create(req, imageUrl: imageUrl);
  }

  Future<void> update(String eventId, UpdateEventRequest req) async {
    await _ref.read(eventRepositoryProvider).update(eventId, req);
  }

  Future<void> delete(String eventId) async {
    await _ref.read(eventRepositoryProvider).delete(eventId);
  }

  Future<void> toggleFavorite(String eventId) async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) throw StateError('Sign in required.');
    await _ref.read(userRepositoryProvider).toggleFavorite(uid, eventId);
  }

  Future<void> toggleRsvp(String eventId) async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) throw StateError('Sign in required.');
    await _ref.read(userRepositoryProvider).toggleRsvp(uid, eventId);
  }
}

final eventActionsProvider = Provider<EventActions>((ref) {
  return EventActions(ref);
});
