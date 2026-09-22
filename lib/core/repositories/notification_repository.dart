import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/constants/firestore_paths.dart';
import 'package:event_management_system/core/providers/firebase_providers.dart';
import 'package:event_management_system/features/settings/models/notification_model.dart';

class NotificationRepository {
  NotificationRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection(FirestorePaths.userNotifications(uid));

  NotificationModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return NotificationModel.fromJson({...?doc.data(), 'id': doc.id});
  }

  Stream<List<NotificationModel>> watch(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  Future<void> markAsRead(String uid, String notificationId) {
    return _col(uid).doc(notificationId).set({
      'isUnread': false,
      'readAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> markAllAsRead(String uid) async {
    final snap = await _col(uid).where('isUnread', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.set(doc.reference, {
        'isUnread': false,
        'readAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(firebaseFirestoreProvider));
});
