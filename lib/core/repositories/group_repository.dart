import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/constants/firestore_paths.dart';
import 'package:event_management_system/core/providers/firebase_providers.dart';
import 'package:event_management_system/features/community/models/group_dto.dart';
import 'package:event_management_system/features/community/models/group_profile_model.dart';

class GroupRepository {
  GroupRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestorePaths.groups);

  Future<GroupProfileState?> getById(String groupId) async {
    final snap = await _col.doc(groupId).get();
    if (!snap.exists) return null;
    return GroupProfileState.fromJson({...?snap.data(), 'groupId': snap.id});
  }

  Stream<GroupProfileState?> watch(String groupId) {
    return _col.doc(groupId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return GroupProfileState.fromJson({...?snap.data(), 'groupId': snap.id});
    });
  }

  Future<void> join(JoinGroupRequest req, String uid) async {
    final groupRef = _col.doc(req.groupId);
    final memberRef = _db
        .collection(FirestorePaths.userMemberships(uid))
        .doc(req.groupId);

    await _db.runTransaction((tx) async {
      final groupSnap = await tx.get(groupRef);
      final memberSnap = await tx.get(memberRef);

      final alreadyJoined = memberSnap.exists;
      final currentCount =
          (groupSnap.data()?['memberCount'] as num?)?.toInt() ?? 0;

      if (req.join && !alreadyJoined) {
        tx.set(memberRef, {
          'groupId': req.groupId,
          'joinedAt': FieldValue.serverTimestamp(),
        });
        tx.set(groupRef, {
          'memberCount': currentCount + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else if (!req.join && alreadyJoined) {
        tx.delete(memberRef);
        tx.set(groupRef, {
          'memberCount': (currentCount - 1).clamp(0, 1 << 31),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> setMuted(MuteGroupRequest req, String uid) async {
    final memberRef = _db
        .collection(FirestorePaths.userMemberships(uid))
        .doc(req.groupId);
    await memberRef.set({
      'muted': req.muted,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<GroupMembership> getMembership(String uid, String groupId) async {
    final snap = await _db
        .collection(FirestorePaths.userMemberships(uid))
        .doc(groupId)
        .get();
    if (!snap.exists) return GroupMembership.none;
    return GroupMembership(
      joined: true,
      muted: snap.data()?['muted'] as bool? ?? false,
    );
  }

  Stream<List<GroupProfileState>> watchAll() {
    return _col.snapshots().map((snap) {
      return snap.docs
          .map(
            (doc) =>
                GroupProfileState.fromJson({...doc.data(), 'groupId': doc.id}),
          )
          .toList();
    });
  }
}

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(ref.watch(firebaseFirestoreProvider));
});
