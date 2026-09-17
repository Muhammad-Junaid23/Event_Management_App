import 'package:event_management_system/features/settings/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_management_system/app/constants/app_assets.dart';

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier()
    : super(
        UserModel(
          id: 'usr_001',
          name: 'Morgan Mill',
          email: 'example23@gmail.com',
          profileImagePath: AppAssets.user1,
        ),
      );

  Future<void> updateProfile({String? newName, String? newImagePath}) async {
    // Ready for API call: await apiService.updateProfile(...)
    state = state.copyWith(name: newName, profileImagePath: newImagePath);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});
