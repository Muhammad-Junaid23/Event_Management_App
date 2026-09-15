import 'package:event_management_system/features/community/presentation/community_screen.dart';
import 'package:event_management_system/features/event_details/presentation/create_event_screen.dart';
import 'package:event_management_system/features/event_details/presentation/create_vote_screen.dart';
import 'package:event_management_system/features/event_details/presentation/event_details_screen.dart';
import 'package:event_management_system/features/favorites/presentation/favourite_screen.dart';
import 'package:event_management_system/features/features_tab/presentation/features_screen.dart';
import 'package:event_management_system/features/community/presentation/group_profile_screen.dart';
import 'package:event_management_system/features/settings/presentation/edit_profile_screen.dart';
import 'package:event_management_system/features/settings/presentation/notification_screen.dart';
import 'package:event_management_system/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:event_management_system/core/widgets/main_wrapper.dart';
import 'package:event_management_system/features/splash/presentation/splash_screen.dart';
import 'package:event_management_system/features/onboarding/presentation/onboarding_screen.dart';
import 'package:event_management_system/features/auth/presentation/login_screen.dart';
import 'package:event_management_system/features/auth/presentation/signup_screen.dart';
import 'package:event_management_system/features/home/presentation/home_screen.dart';

class AppRoutes {
  // Static Route Paths
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String features = '/features';
  static const String community = '/community';
  static const String favourite = '/favourite';
  static const String settings = '/settings';
  static const String groupProfile = '/group-profile';
  static const String eventDetails = '/event-details';
  static const String editProfile = '/edit-profile';
  static const String notification = '/notification';
  static const String createEvent = '/create-event';
  static const String createVote = '/create-vote';

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: splash,
    routes: [
      // Standalone Auth & Entry Routes
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: signup, builder: (context, state) => const SignUpScreen()),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: notification,
        builder: (context, state) => NotificationScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: groupProfile,
        builder: (context, state) {
          // Extract the map passed via `extra` during context.push()
          final args = state.extra as Map<String, dynamic>?;
          final groupName =
              args?['groupName'] ?? 'Business group'; // Fallback default name

          return GroupProfileScreen(groupName: groupName);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: eventDetails,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final eventId = extra?['eventId'] as String? ?? '';
          return EventDetailsScreen(eventId: eventId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: createEvent,
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: createVote,
        builder: (context, state) => const CreateVoteScreen(),
      ),

      // Bottom Navigation Stateful Shell Routes
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: features,
                builder: (context, state) => const FeaturesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: community,
                builder: (context, state) => const CommunityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: favourite,
                builder: (context, state) => const FavouriteScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
