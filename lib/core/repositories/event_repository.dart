import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/constants/firestore_paths.dart';
import 'package:event_management_system/core/providers/firebase_providers.dart';
import 'package:event_management_system/features/home/models/event_dto.dart';
import 'package:event_management_system/features/home/models/event_model.dart';

class EventRepository {
  EventRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.events);

  EventModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return EventModel.fromJson({...?doc.data(), 'id': doc.id});
  }

  Stream<List<EventModel>> watchAll() {
    return _col
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  Future<List<EventModel>> getAll() async {
    final snap = await _col.orderBy('dateTime').get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<EventModel?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    return _fromDoc(snap);
  }

  Future<EventModel> create(CreateEventRequest req, {String? imageUrl}) async {
    final payload = req.toJson(imageUrl: imageUrl);
    payload['createdAt'] = FieldValue.serverTimestamp();
    payload['updatedAt'] = FieldValue.serverTimestamp();

    final ref = await _col.add(payload);
    final created = await ref.get();
    return _fromDoc(created);
  }

  Future<void> update(String id, UpdateEventRequest req) async {
    final data = req.toJson();
    if (data.isEmpty) return;
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _col.doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<List<EventModel>> getFavorites(List<String> eventIds) async {
    if (eventIds.isEmpty) return [];
    // Firestore whereIn has a 10-item cap; chunk if needed later.
    final chunks = <List<String>>[];
    for (var i = 0; i < eventIds.length; i += 10) {
      chunks.add(
        eventIds.sublist(
          i,
          i + 10 > eventIds.length ? eventIds.length : i + 10,
        ),
      );
    }
    final results = <EventModel>[];
    for (final chunk in chunks) {
      final snap = await _col.where(FieldPath.documentId, whereIn: chunk).get();
      results.addAll(snap.docs.map(_fromDoc));
    }
    return results;
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(firebaseFirestoreProvider));
});
