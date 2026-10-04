import 'package:go_router/go_router.dart';
import '../features/auth/data/auth_service.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/home/presentation/dashboard_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
abstract final class AppRoutes {
  static const onboarding =
      '/onboarding';

  static const login =
      '/login';

  static const register =
      '/register';

  static const dashboard =
      '/dashboard';

  static const checkIn =
      '/check-in';

  static const preRegister =
      '/pre-register';

  static const scanQr =
      '/scan-qr';

  static const visitors =
      '/visitors';
}

GoRouter createRouter({
  required bool hasCompletedOnboarding,
}) {
  final loggedIn =
      AuthService.instance.currentSession != null;

  return GoRouter(
    initialLocation: !hasCompletedOnboarding
        ? AppRoutes.onboarding
        : loggedIn
        ? AppRoutes.dashboard
        : AppRoutes.login,

    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) =>
        const OnboardingScreen(),
      ),

      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) =>
        const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) =>
        const RegisterScreen(),
      ),

      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, _) =>
        const DashboardScreen(),
      ),
    ],
  );
}