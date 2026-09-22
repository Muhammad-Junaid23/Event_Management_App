import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/constants/firestore_paths.dart';
import 'package:event_management_system/core/providers/firebase_providers.dart';
import 'package:event_management_system/features/community/models/community_poll_model.dart';
import 'package:event_management_system/features/community/models/poll_dto.dart';

class PollRepository {
  PollRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.polls);

  PollModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return PollModel.fromJson({...?doc.data(), 'id': doc.id});
  }

  Stream<List<PollModel>> watchAll() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  Stream<List<PollModel>> watchByGroup(String groupId) {
    return _col
        .where('group', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  Future<PollModel> create(CreatePollRequest req, {String? imageUrl}) async {
    final payload = <String, dynamic>{
      'question': req.question,
      'options': req.options
          .map((text) => {'id': '', 'text': text, 'votes': 0})
          .toList(),
      'group': req.groupId,
      'imageUrl': imageUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final ref = await _col.add(payload);
    final created = await ref.get();
    return _fromDoc(created);
  }

  /// Atomic vote. Removes previous vote if the user changes their mind.
  Future<void> vote({required String uid, required VoteRequest req}) async {
    final pollRef = _col.doc(req.pollId);
    final voteRef = pollRef.collection('votes').doc(uid);

    await _db.runTransaction((tx) async {
      final pollSnap = await tx.get(pollRef);
      if (!pollSnap.exists) {
        throw StateError('Poll not found: ${req.pollId}');
      }
      final data = pollSnap.data() ?? {};
      final rawOptions = (data['options'] as List?) ?? [];

      final voteSnap = await tx.get(voteRef);
      final previousOptionId = voteSnap.data()?['optionId'] as String?;

      if (previousOptionId == req.optionId) return; // no-op

      final updated = rawOptions.map((raw) {
        final option = Map<String, dynamic>.from(raw as Map);
        final id = option['id'] as String? ?? '';
        final votes = (option['votes'] as num?)?.toInt() ?? 0;
        if (id == req.optionId) {
          option['votes'] = votes + 1;
        } else if (id == previousOptionId) {
          option['votes'] = (votes - 1).clamp(0, 1 << 31);
        }
        return option;
      }).toList();

      tx.update(pollRef, {
        'options': updated,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(voteRef, {
        'optionId': req.optionId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  return PollRepository(ref.watch(firebaseFirestoreProvider));
});
