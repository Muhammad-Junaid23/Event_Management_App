import 'package:event_management_system/features/onboarding/presentation/onboarding_screen.dart';
import 'package:event_management_system/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Login Screen'))),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Signup Screen'))),
      ),
    ],
  );
}
