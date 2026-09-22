import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/providers/firebase_providers.dart';

class StorageRepository {
  StorageRepository(this._storage);

  final FirebaseStorage _storage;

  Future<String> _upload({
    required String folder,
    required String userId,
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
    void Function(double progress)? onProgress,
  }) async {
    final safeName = fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref('$folder/$userId/${stamp}_$safeName');

    final task = ref.putData(bytes, SettableMetadata(contentType: contentType));

    if (onProgress != null) {
      task.snapshotEvents.listen((snap) {
        if (snap.totalBytes > 0) {
          onProgress(snap.bytesTransferred / snap.totalBytes);
        }
      });
    }

    final done = await task;
    return done.ref.getDownloadURL();
  }

  Future<String> uploadEventImage({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) {
    return _upload(
      folder: 'events',
      userId: userId,
      bytes: bytes,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  Future<String> uploadPollImage({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) {
    return _upload(
      folder: 'polls',
      userId: userId,
      bytes: bytes,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) {
    return _upload(
      folder: 'avatars',
      userId: userId,
      bytes: bytes,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Best-effort delete. Ignores failures (external URLs, already gone).
  Future<void> deleteByUrl(String url) async {
    if (!url.startsWith('http')) return;
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {
      // ignore
    }
  }
}

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(ref.watch(firebaseStorageProvider));
});
