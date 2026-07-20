import 'package:go_router/go_router.dart';

import 'package:marriage_hall_app/constants/routes.dart';
import 'package:marriage_hall_app/models/user_role.dart';
import 'package:marriage_hall_app/screens/auth/forgot_password_screen.dart';
import 'package:marriage_hall_app/screens/auth/login_screen.dart';
import 'package:marriage_hall_app/screens/auth/register_screen.dart';
import 'package:marriage_hall_app/screens/admin/admin_shell_screen.dart';
import 'package:marriage_hall_app/screens/auth/role_selection_screen.dart';
import 'package:marriage_hall_app/screens/client/client_shell_screen.dart';
import 'package:marriage_hall_app/screens/owner/owner_dashboard_screen.dart';
import 'package:marriage_hall_app/screens/splash/splash_screen.dart';

/// The dashboard a user of the given role belongs on — the single place
/// login/splash/role-change routing decisions come from, so an admin can
/// never end up on the owner dashboard.
String homeRouteForRole(UserRole? role) => switch (role) {
  UserRole.admin => AppRoutes.admin,
  UserRole.hallOwner => AppRoutes.ownerDashboard,
  _ => AppRoutes.home,
};

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splashName,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.roles,
      name: AppRoutes.rolesName,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.loginName,
      builder: (context, state) =>
          LoginScreen(role: state.extra as UserRole? ?? UserRole.client),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: AppRoutes.registerName,
      builder: (context, state) =>
          RegisterScreen(role: state.extra as UserRole? ?? UserRole.client),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: AppRoutes.forgotPasswordName,
      builder: (context, state) =>
          ForgotPasswordScreen(role: state.extra as UserRole?),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.homeName,
      builder: (context, state) => const ClientShellScreen(),
    ),
    GoRoute(
      path: AppRoutes.ownerDashboard,
      name: AppRoutes.ownerDashboardName,
      builder: (context, state) => const OwnerDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.admin,
      name: AppRoutes.adminName,
      builder: (context, state) => const AdminShellScreen(),
    ),
  ],
);
