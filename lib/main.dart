import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.validate();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );

  final hasCompletedOnboarding =
  await PreferencesService.hasCompletedOnboarding();

  runApp(
    VisitorProApp(
      hasCompletedOnboarding: hasCompletedOnboarding,
    ),
  );
}