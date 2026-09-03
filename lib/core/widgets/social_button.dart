import 'package:event_management_system/app/constants/app_assets.dart';
import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GoogleAuthButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleAuthButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(
          color: isDark ? AppColors.darkBorderInput : AppColors.borderInput,
          width: 0.4,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAssets.googleIcon, height: 20, width: 20),
          const SizedBox(width: 12),
          Text(
            'Continue with google',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
