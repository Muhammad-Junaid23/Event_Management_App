import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:event_management_system/core/providers/firebase_providers.dart';

class StorageRepository {
  StorageRepository(this._storage);

  final FirebaseStorage _storage;

  /// Uploads bytes and returns the public download URL.
  Future<String> _upload({
    required String folder,
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final safeName = fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref('$folder/$userId/${stamp}_$safeName');

    final task = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return task.ref.getDownloadURL();
  }

  Future<String> uploadEventImage({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return _upload(
      folder: 'events',
      userId: userId,
      bytes: bytes,
      fileName: fileName,
    );
  }

  Future<String> uploadPollImage({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return _upload(
      folder: 'polls',
      userId: userId,
      bytes: bytes,
      fileName: fileName,
    );
  }

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return _upload(
      folder: 'avatars',
      userId: userId,
      bytes: bytes,
      fileName: fileName,
    );
  }

  /// Best-effort delete. Fails silently if the URL is not a Storage URL.
  Future<void> deleteByUrl(String url) async {
    if (!url.startsWith('http')) return;
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {
      // ignore — may be an external URL or already deleted
    }
  }
}

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(ref.watch(firebaseStorageProvider));
});
