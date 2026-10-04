import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class VisitorProApp extends StatelessWidget {
  const VisitorProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'VisitorPro',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}