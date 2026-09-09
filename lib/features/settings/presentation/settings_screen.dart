import 'package:event_management_system/app/config/routes.dart';
import 'package:event_management_system/features/settings/presentation/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_assets.dart';

class SettingsScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String profileImagePath;

  const SettingsScreen({
    super.key,
    this.userName = 'Morgan mill',
    this.userEmail = 'example23@gmail.com',
    this.profileImagePath = AppAssets.user1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: Text(
          'Setting',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(profileImagePath),
            ),
            const SizedBox(height: 12),

            // User Info
            Text(
              userName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
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
              onTap: () {
                context.push(AppRoutes.notification);
              },
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
              onTap: () {},
            ),
            _buildSettingTile(
              context,
              icon: Icons.logout,
              title: 'Logout',
              isLogout: true,
              onTap: () {},
            ),
          ],
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
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
          ),
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
