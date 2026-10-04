import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class VisitorProApp extends StatelessWidget {
  const VisitorProApp({
    super.key,
    required this.hasCompletedOnboarding,
  });

  final bool hasCompletedOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'VisitorPro',
      theme: AppTheme.lightTheme,
      routerConfig: createRouter(
        hasCompletedOnboarding:
        hasCompletedOnboarding,
      ),
    );
  }
}