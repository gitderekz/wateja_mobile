import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_notifier.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/dashboard/dashboard_layout.dart';
import 'screens/dashboard/home_page_screen.dart';
import 'screens/dashboard/lessons_screen.dart';
import 'screens/dashboard/lesson_detail_screen.dart';
import 'screens/dashboard/cart_items_screen.dart';
import 'screens/dashboard/orders_screen.dart';
import 'screens/dashboard/receipts_screen.dart';
import 'screens/dashboard/messages_screen.dart';
import 'screens/dashboard/notifications_screen.dart';
import 'screens/dashboard/settings_screen.dart';
import 'screens/dashboard/users_management_screen.dart';
import 'screens/dashboard/stock_management_screen.dart';
import 'screens/dashboard/reports_screen.dart';
import 'screens/dashboard/blog_management_screen.dart';
import 'screens/dashboard/new_products_screen.dart';
import 'screens/dashboard/my_products_screen.dart';
import 'screens/dashboard/selling_screen.dart';
import 'screens/dashboard/buying_screen.dart';
import 'screens/dashboard/system_logs_screen.dart';
import 'screens/dashboard/consultation_screen.dart';

GoRouter createRouter(Listenable refreshListenable) {
  return GoRouter(
    refreshListenable: refreshListenable,
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = context.read<AuthNotifier>();
      final isAuth = auth.isAuthenticated;
      final loc = state.uri.path;
      final loggingIn = loc == '/login' || loc == '/signup' || loc == '/forgot-password' || loc.startsWith('/reset-password');
      if (!isAuth && !loggingIn) return '/login';
      if (isAuth && (loc == '/login' || loc == '/signup')) return '/dashboard/home';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),

      ShellRoute(
        builder: (context, state, child) => DashboardLayout(child: child),
        routes: [
          GoRoute(path: '/dashboard/home', builder: (c, s) => const HomePageScreen()),
          GoRoute(path: '/dashboard/market', builder: (c, s) => const SellingScreen()),
          GoRoute(path: '/dashboard/selling', builder: (c, s) => const SellingScreen()),
          GoRoute(path: '/dashboard/consultation', builder: (c, s) => const ConsultationScreen()),
          GoRoute(path: '/dashboard/lessons', builder: (c, s) => const LessonsScreen()),
          GoRoute(path: '/dashboard/lessons/:id', builder: (c, s) => LessonDetailScreen(id: s.pathParameters['id'])),
          GoRoute(path: '/dashboard/cart', builder: (c, s) => const CartItemsScreen()),
          GoRoute(path: '/dashboard/orders', builder: (c, s) => const OrdersScreen()),
          GoRoute(path: '/dashboard/receipts', builder: (c, s) => const ReceiptsScreen()),
          GoRoute(path: '/dashboard/messages', builder: (c, s) => const MessagesScreen()),
          GoRoute(path: '/dashboard/notifications', builder: (c, s) => const NotificationsScreen()),
          GoRoute(path: '/dashboard/settings', builder: (c, s) => const SettingsScreen()),
          GoRoute(path: '/dashboard/users', builder: (c, s) => const UsersManagementScreen()),
          GoRoute(path: '/dashboard/stock', builder: (c, s) => const StockManagementScreen()),
          GoRoute(path: '/dashboard/reports', builder: (c, s) => const ReportsScreen()),
          GoRoute(path: '/dashboard/blog', builder: (c, s) => const BlogManagementScreen()),
          GoRoute(path: '/dashboard/new-products', builder: (c, s) => const NewProductsScreen()),
          GoRoute(path: '/dashboard/my-products', builder: (c, s) => const MyProductsScreen()),
          GoRoute(path: '/dashboard/selling', builder: (c, s) => const SellingScreen()),
          GoRoute(path: '/dashboard/buying', builder: (c, s) => const BuyingScreen()),
          GoRoute(path: '/dashboard/system-logs', builder: (c, s) => const SystemLogsScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
