import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/config/routes.dart';
import 'app/config/theme.dart';

void main() {
  runApp(const ProviderScope(child: EventManagementApp()));
}

class EventManagementApp extends StatelessWidget {
  const EventManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Event Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRoutes.router,
    );
  }
}
