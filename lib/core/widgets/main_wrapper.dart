import 'package:event_management_system/core/widgets/app_lifecycle_reloader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:event_management_system/app/constants/app_colors.dart';

class MainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppLifecycleReloader(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.background,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(
                  0,
                  -4,
                ), // Negative Y value projects shadow to the top
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onTap,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark
                ? AppColors.darkTextMuted
                : AppColors.textMuted,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
            backgroundColor: isDark
                ? AppColors.darkSurface
                : AppColors.background,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.pets_outlined),
                activeIcon: Icon(Icons.pets),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_outline),
                activeIcon: Icon(Icons.star),
                label: 'Features',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups_outlined),
                activeIcon: Icon(Icons.groups),
                label: 'Community',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Favourite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
