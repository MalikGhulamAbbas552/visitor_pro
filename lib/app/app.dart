import 'package:flutter/material.dart';

import '../features/onboarding/presentation/onboarding_screen.dart';
import 'theme.dart';

class VisitorProApp extends StatelessWidget {
  const VisitorProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Visitor Pro',
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}