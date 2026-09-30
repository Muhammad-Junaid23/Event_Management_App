import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/constants/firestore_paths.dart';
import 'package:event_management_system/core/providers/firebase_providers.dart';
import 'package:event_management_system/features/auth/domain/user_model.dart';
import 'package:event_management_system/features/settings/models/user_dto.dart';

class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _ref(String uid) =>
      _db.collection(FirestorePaths.users).doc(uid);

  Future<UserModel?> getById(String uid) async {
    final snap = await _ref(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return UserModel.fromJson({...data, 'id': snap.id});
  }

  Stream<UserModel?> watch(String uid) {
    return _ref(uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return UserModel.fromJson({...data, 'id': snap.id});
    });
  }

  /// Called at signup to seed the user document.
  Future<void> createIfMissing({
    required String uid,
    required String name,
    required String email,
  }) async {
    final ref = _ref(uid);
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set({
      'name': name,
      'email': email,
      'profileImagePath': '',
      'bio': null,
      'favoriteEventIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProfile(String uid, UpdateProfileRequest req) async {
    final data = req.toJson();
    if (data.isEmpty) return;
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _ref(uid).set(data, SetOptions(merge: true));
  }

  /// Favorites live on the user document to avoid needing a separate collection.
  Future<void> toggleFavorite(String uid, String eventId) async {
    final ref = _ref(uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};
      final favs = (data['favoriteEventIds'] as List?)?.cast<String>() ?? [];
      final has = favs.contains(eventId);
      final updated = has ? (favs..remove(eventId)) : (favs..add(eventId));
      tx.set(ref, {'favoriteEventIds': updated}, SetOptions(merge: true));
    });
  }

  Stream<List<String>> watchFavoriteIds(String uid) {
    return _ref(uid).snapshots().map((snap) {
      final raw = snap.data()?['favoriteEventIds'];
      return raw is List ? raw.cast<String>() : const <String>[];
    });
  }

  Stream<List<String>> watchRsvpIds(String uid) {
    return _ref(uid).snapshots().map((snap) {
      final raw = snap.data()?['rsvpEventIds'];
      return raw is List ? raw.cast<String>() : const <String>[];
    });
  }

  Future<void> toggleRsvp(String uid, String eventId) async {
    final ref = _ref(uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};
      final list = (data['rsvpEventIds'] as List?)?.cast<String>() ?? [];
      final has = list.contains(eventId);
      final updated = has ? (list..remove(eventId)) : (list..add(eventId));
      tx.set(ref, {'rsvpEventIds': updated}, SetOptions(merge: true));
    });
  }

  Future<void> updateFcmToken(String uid, String token) async {
    await _ref(uid).set({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firebaseFirestoreProvider));
});
