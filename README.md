## Guiding principle

**Don’t rewrite screens.** Change what’s _behind_ the providers. If a screen does `ref.watch(eventProvider)`, keep that name and shape — just change the notifier to fetch from Firebase. That way the UI never breaks.

Do this in **phases**. Finish and test one phase before starting the next.

---

## Phase 0 — Freeze & branch (do this first)

1. Commit current working demo as a tag, e.g. `demo-stable`.
2. Create branch `feat/firebase-integration`.
3. Add Firebase now, but don’t use it yet:
   ```yaml
   firebase_core
   cloud_firestore
   firebase_auth
   firebase_storage
   firebase_messaging
   cloud_functions # if you use them
   ```
4. Run `flutterfire configure`. Verify `main.dart` still runs the demo. If yes, you have a safety net.

At this point the app **behaves exactly the same**. That’s the goal of Phase 0.

---

## Phase 1 — Small fixes that must happen before backend

Do these now because they’ll bite you during integration.

1. **Fix `buildSmartImage`** — right now `assets/...` paths fall through to `File(...)`. Add the asset check first. Without this, event images will silently break when URLs change.

2. **Replace `Image.asset(event.imageUrl)` with `buildSmartImage(...)`** in:
   - `event_details_screen.dart`
   - `home/presentation/widgets/event_card.dart`
   - `group_profile_screen.dart`

   Firebase will return `https://...` URLs; `Image.asset` will throw.

3. **Add `mounted` guards** after every `await` that calls `setState`. You already do this in some places; do it everywhere.

4. **Fix logout** — it currently only invalidates the mock user. It must call `authProvider.notifier.logout()`.

5. **Persist theme** — save `ThemeMode` in `SharedPreferences`. Without this, users will complain the moment you ship.

None of these change the UI. They just make it safe.

---

## Phase 2 — Model layer (no UI change yet)

Backend returns JSON. Your models must survive that JSON.

For each model, add `fromJson` / `toJson` and make parsing **defensive**:

- `EventModel` — already has JSON, but harden it:
  - `dateTime`: Firebase gives `Timestamp`, REST gives ISO string, mock gives ISO. Write a helper:
    ```dart
    static DateTime _parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.parse(v);
      return DateTime.now();
    }
    ```
  - `id`: Firebase doc ID, not from JSON body. Handle `id` being absent.
  - `imageUrl`: `as String? ?? ''`.
  - Remove `isFavorite` from the event document. Favorites belong in a `user_favorites/{uid}/events/{eventId}` collection. Keep the field in the model if you want, but populate it from a separate lookup.

- Add `fromJson` / `toJson` to `PollModel`, `PollOption`, `NotificationModel`, `UserModel`, `GroupProfileState`.

- **Unify `UserModel`** — you have two copies. Delete `features/settings/models/user_model.dart` and import the one in `features/auth/domain/`.

- Create **request DTOs** separate from models:
  - `CreateEventRequest`, `CreatePollRequest`, `VoteRequest`, `UpdateProfileRequest`, `JoinGroupRequest`.
  - These don’t include `id`, `isFavorite`, `createdAt` — the backend sets those.

Still no UI change. The demo still works.

---

## Phase 3 — Repository layer (still no UI change)

Introduce repositories that own Firebase. Providers will call these. **Nothing in the UI changes yet**, because the demo providers still hit local data.

Create:

- `AuthRepository` — signup, login, google, logout, currentUser, token
- `EventRepository` — stream/list, getById, create, update, delete, toggleFavorite
- `PollRepository` — stream/list, create, vote
- `GroupRepository` — get, join, leave, mute
- `NotificationRepository` — stream, markRead
- `UserRepository` — get, update, uploadAvatar
- `StorageRepository` — upload images, return download URL

Each repository takes `FirebaseFirestore`, `FirebaseAuth`, `FirebaseStorage` via constructor. Expose via Riverpod `Provider`. This is where Firebase SDK lives — nowhere else.

Rule: **no screen or notifier imports Firebase directly.** Only repositories.

---

## Phase 4 — Storage service for images (needed before events/polls)

Right now `CreateEventScreen` saves `imageUrl: _selectedImage?.path` — a local file path. That will break the moment you switch to Firebase.

Add to `StorageRepository`:

```dart
Future<String> uploadEventImage(XFile file, String userId);
Future<String> uploadPollImage(XFile file, String userId);
Future<String> uploadAvatar(XFile file, String userId);
```

On web, `XFile` has `readAsBytes()`. On mobile, use `File(file.path)`. Wrap with `kIsWeb` check.

Also: show upload progress and handle failure. Otherwise the create screen will look “stuck”.

---

## Phase 5 — Provider swap, one feature at a time

This is the actual integration. **Do one feature per PR**, test, merge, next.

Order (easiest → hardest):

1. **Theme** — already local. Add persistence. 30 min.
2. **Notifications** — read-only list. Good warmup for Firebase.
3. **Group profile** — small state.
4. **Polls** — create + vote. Watch out: voting needs a transaction to avoid double-vote.
5. **Events** — biggest one. Split first:
   - `eventsProvider` → `AsyncNotifier<AsyncValue<List<EventModel>>>` from Firestore.
   - `eventFiltersProvider` → `Notifier<EventFilters>` (city, state, group, category).
   - `selectedDateProvider` → `Notifier<DateTime>`.
   - `filteredEventsProvider` → derived (unchanged signature, screens don’t care).
   - `selectedDateEventsProvider` → derived.
   - `favoriteEventsProvider` → derived or from `user_favorites`.
6. **Auth** — last, because everything else depends on `uid`. Do this after events work.

For each swap, keep the **provider name and public state shape** if possible. If a screen does:

```dart
final events = ref.watch(filteredEventsProvider);
```

Keep that exact line working. Only the internals change.

Where the shape _must_ change (e.g. `List` → `AsyncValue<List>`), update that one screen. That’s the only place UI code touches.

---

## Phase 6 — Auth + routing

Once repositories and providers are Firebase-backed:

1. Implement `AuthRepository` with `firebase_auth`.
2. `AuthState` gains `user`, `token`, `isLoading`, `error`.
3. Add a **GoRouter `redirect`**:
   ```dart
   redirect: (context, state) {
     final auth = ref.read(authProvider);
     final loggingIn = state.matchedLocation == AppRoutes.login
         || state.matchedLocation == AppRoutes.signup;
     if (!auth.isLoggedIn && !loggingIn) return AppRoutes.login;
     if (auth.isLoggedIn && loggingIn) return AppRoutes.home;
     return null;
   }
   ```
4. Add `refreshListenable` so router re-runs on auth change.
5. Replace hardcoded `context.go('/home')` with `context.go(AppRoutes.home)`.
6. Switch `eventDetails` and `groupProfile` to **path params** (`/event-details/:eventId`) so web refresh works.

---

## Phase 7 — Firebase setup in `main.dart`

Now wire Firebase:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const EventManagementApp(),
  ));
}
```

Don’t call `Firebase.initializeApp` inside providers. One call, in `main`.

---

## Phase 8 — Cleanup

Once everything is Firebase-backed:

- Delete mock data from notifiers (`EventNotifier` mock events, `NotificationNotifier` seed list, `GroupProfileNotifier` mock group, `UserNotifier` mock user).
- Remove the “Add Test” button from `NotificationScreen`.
- Remove `featuresEventProvider` (unused duplicate).
- Remove `AuthApiService` if you’re going full Firebase, or keep it for REST fallback.
- Remove `loginWithCredentials` mock branch.

---

## Rules that keep you from breaking the app

1. **Never change a screen and a provider in the same PR.** One or the other.
2. **Keep the demo branch alive.** If Firebase integration hits a wall, you can still demo.
3. **One feature per PR.** Merge, test on web + Android + iOS, next.
4. **Screens only know providers, providers only know repositories, repositories only know Firebase.**
5. **Don’t leak Firestore types** (`Timestamp`, `DocumentSnapshot`) into models or providers — convert at the repository boundary.
6. **Don’t remove mock data until the Firebase version is verified.** Toggle with a flag if needed:
   ```dart
   const useFirebase = bool.fromEnvironment('USE_FIREBASE');
   ```
   Override providers in `main.dart` based on the flag. This lets you flip back instantly.

---
