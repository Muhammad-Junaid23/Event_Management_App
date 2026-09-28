import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/core/utils/cloudinary_url.dart';
import 'package:event_management_system/core/utils/error_messages.dart';
import 'package:event_management_system/features/settings/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:event_management_system/features/auth/providers/auth_provider.dart';
import 'package:event_management_system/features/settings/providers/notification_provider.dart';
import 'package:event_management_system/features/community/providers/community_polls_provider.dart';
import 'package:event_management_system/features/community/providers/group_profile_provider.dart';

import 'package:event_management_system/app/config/routes.dart';
import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/features/settings/providers/user_provider.dart';
import 'package:event_management_system/core/widgets/custom_image_wrapper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    final isDark = themeMode == ThemeMode.system
        ? platformBrightness == Brightness.dark
        : themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: ref
          .watch(userProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(friendlyError(e))),
            data: (user) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // User Avatar with Smart Image Support
                  ClipOval(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: buildSmartImage(
                        (user?.profileImagePath.isEmpty ?? true)
                            ? AppAssets.user1
                            : cloudinaryAvatar(
                                user!.profileImagePath,
                                size: 200,
                              ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // User Info
                  Text(
                    user?.name ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textUserEmail,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Edit Profile Button
                  SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push(AppRoutes.editProfile);
                      },
                      icon: const Icon(
                        Icons.edit_note_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Settings Options List
                  _buildSettingTile(
                    context,
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () => context.push(AppRoutes.notification),
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.article_outlined,
                    title: 'Term & Conditions',
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.share_outlined,
                    title: 'Invite Your Friend',
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) {
                        ref
                            .read(themeProvider.notifier)
                            .setTheme(value ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    isLogout: true,
                    onTap: () {
                      // Show confirmation dialog before erasing
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to log out?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // 1. Dismiss the dialog
                                Navigator.pop(dialogContext);

                                // 2. Clear auth + reset providers
                                await ref.read(authProvider.notifier).logout();
                                ref.invalidate(userProvider);
                                ref.invalidate(notificationProvider);
                                ref.invalidate(communityPollsProvider);
                                ref.invalidate(groupProfileProvider);

                                // 3. Navigate to login
                                if (context.mounted) {
                                  context.go(AppRoutes.login);
                                }
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            icon,
            color: isLogout
                ? AppColors.primary
                : (isDark ? Colors.white70 : Colors.black87),
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isLogout
                  ? AppColors.primary
                  : (isDark ? Colors.white : Colors.black),
            ),
          ),
          trailing:
              trailing ??
              (isLogout
                  ? null
                  : const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    )),
          onTap: onTap,
        ),
        if (!isLogout)
          const Divider(
            height: 1,
            thickness: 0.6,
            color: AppColors.borderDivider,
          ),
      ],
    );
  }
}
