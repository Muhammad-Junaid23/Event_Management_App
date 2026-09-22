import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:event_management_system/core/providers/firebase_providers.dart';
import 'package:event_management_system/core/repositories/storage_repository.dart';

enum ImageBucket { event, poll, avatar }

/// Adapter between image_picker's XFile and StorageRepository's Uint8List.
/// Owns the conversion and the "which uid" resolution. Screens talk only to
/// this class.
class ImageUploadService {
  ImageUploadService(this._repo, this._auth);

  final StorageRepository _repo;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No signed-in user — image upload requires auth.');
    }
    return uid;
  }

  String _fileNameFromXFile(XFile file) {
    if (file.name.isNotEmpty) return file.name;
    final path = file.path;
    final slash = path.lastIndexOf(RegExp(r'[\\/]'));
    final name = slash >= 0 ? path.substring(slash + 1) : path;
    return name.isEmpty ? 'image.jpg' : name;
  }

  Future<String> upload({
    required XFile file,
    required ImageBucket bucket,
    void Function(double progress)? onProgress,
  }) async {
    final Uint8List bytes = await file.readAsBytes();
    final name = _fileNameFromXFile(file);
    final uid = _uid;

    switch (bucket) {
      case ImageBucket.event:
        return _repo.uploadEventImage(
          userId: uid,
          bytes: bytes,
          fileName: name,
          onProgress: onProgress,
        );
      case ImageBucket.poll:
        return _repo.uploadPollImage(
          userId: uid,
          bytes: bytes,
          fileName: name,
          onProgress: onProgress,
        );
      case ImageBucket.avatar:
        return _repo.uploadAvatar(
          userId: uid,
          bytes: bytes,
          fileName: name,
          onProgress: onProgress,
        );
    }
  }

  /// Convenience for create/edit screens: if the user didn't pick a new file,
  /// keep the existing URL. Otherwise upload.
  Future<String> uploadOrKeep({
    required XFile? file,
    required ImageBucket bucket,
    String? existingUrl,
    void Function(double progress)? onProgress,
  }) async {
    if (file == null) return existingUrl ?? '';
    return upload(file: file, bucket: bucket, onProgress: onProgress);
  }
}

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService(
    ref.watch(storageRepositoryProvider),
    ref.watch(firebaseAuthProvider),
  );
});
