import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:event_management_system/core/repositories/user_repository.dart';
import 'package:event_management_system/core/services/image_upload_service.dart';
import 'package:event_management_system/features/auth/domain/user_model.dart';
import 'package:event_management_system/features/auth/providers/auth_provider.dart';
import 'package:event_management_system/features/settings/models/user_dto.dart';

// -----------------------------------------------------------------------------
// Stream of the current user's document. Rebuilds on login/logout.
// -----------------------------------------------------------------------------
final userProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watch(uid);
});

// -----------------------------------------------------------------------------
// Actions (update name, upload avatar)
// -----------------------------------------------------------------------------
class UserActions {
  UserActions(this._ref);
  final Ref _ref;

  /// Updates name and/or avatar. If [newImage] is provided, uploads to
  /// Cloudinary first, then writes both fields to Firestore.
  Future<void> updateProfile({
    String? newName,
    XFile? newImage,
    void Function(double progress)? onUploadProgress,
  }) async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) throw StateError('Not signed in.');

    String? imageUrl;
    if (newImage != null) {
      imageUrl = await _ref
          .read(imageUploadServiceProvider)
          .upload(
            file: newImage,
            bucket: ImageBucket.avatar,
            onProgress: onUploadProgress,
          );
    }

    await _ref
        .read(userRepositoryProvider)
        .updateProfile(
          uid,
          UpdateProfileRequest(name: newName, imageUrl: imageUrl),
        );
  }
}

final userActionsProvider = Provider<UserActions>((ref) => UserActions(ref));
