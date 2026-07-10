import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/user_role.dart';
import '../../features/client/presentation/screens/client_shell_screen.dart';
import '../../features/owner/presentation/screens/owner_dashboard_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/roles',
      name: 'roles',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) =>
          LoginScreen(role: state.extra as UserRole? ?? UserRole.client),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) =>
          RegisterScreen(role: state.extra as UserRole? ?? UserRole.client),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const ClientShellScreen(),
    ),
    GoRoute(
      path: '/owner-dashboard',
      name: 'owner-dashboard',
      builder: (context, state) => const OwnerDashboardScreen(),
    ),
  ],
);
