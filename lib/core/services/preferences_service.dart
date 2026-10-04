import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._();

  static final SharedPreferencesAsync _preferences =
  SharedPreferencesAsync();

  static const String _onboardingKey = 'onboarding_completed';

  static Future<bool> hasCompletedOnboarding() async {
    return await _preferences.getBool(_onboardingKey) ?? false;
  }

  static Future<void> completeOnboarding() async {
    await _preferences.setBool(_onboardingKey, true);
  }

  static Future<void> resetOnboarding() async {
    await _preferences.remove(_onboardingKey);
  }
}