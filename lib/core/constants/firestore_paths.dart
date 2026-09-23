/// Central place for collection/document paths.
/// Confirm these with the backend team before Phase 5 swaps providers.
class FirestorePaths {
  FirestorePaths._();

  // Top-level collections
  static const String users = 'users';
  static const String events = 'events';
  static const String polls = 'polls';
  static const String groups = 'groups';

  // Subcollections on users
  static const String favorites =
      'favorites'; // users/{uid}/favorites/{eventId}
  static const String memberships =
      'memberships'; // users/{uid}/memberships/{groupId}
  static const String notifications =
      'notifications'; // users/{uid}/notifications/{notifId}

  static const String pollVotes = 'pollVotes';

  static String userPollVotes(String uid) => '${userDoc(uid)}/$pollVotes';

  // Helpers
  static String userDoc(String uid) => '$users/$uid';
  static String eventDoc(String id) => '$events/$id';
  static String pollDoc(String id) => '$polls/$id';
  static String groupDoc(String id) => '$groups/$id';
  static String userFavorites(String uid) => '${userDoc(uid)}/$favorites';
  static String userMemberships(String uid) => '${userDoc(uid)}/$memberships';
  static String userNotifications(String uid) =>
      '${userDoc(uid)}/$notifications';
}
