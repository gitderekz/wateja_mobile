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
    routes: <GoRoute>[
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),

      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardLayout(),
        routes: [
          GoRoute(path: 'home', builder: (c, s) => const HomePageScreen()),
          GoRoute(path: 'lessons', builder: (c, s) => const LessonsScreen()),
          GoRoute(path: 'lessons/:id', builder: (c, s) => LessonDetailScreen(id: s.pathParameters['id'])),
          GoRoute(path: 'cart', builder: (c, s) => const CartItemsScreen()),
          GoRoute(path: 'orders', builder: (c, s) => const OrdersScreen()),
          GoRoute(path: 'receipts', builder: (c, s) => const ReceiptsScreen()),
          GoRoute(path: 'messages', builder: (c, s) => const MessagesScreen()),
          GoRoute(path: 'notifications', builder: (c, s) => const NotificationsScreen()),
          GoRoute(path: 'settings', builder: (c, s) => const SettingsScreen()),
          GoRoute(path: 'users', builder: (c, s) => const UsersManagementScreen()),
          GoRoute(path: 'stock', builder: (c, s) => const StockManagementScreen()),
          GoRoute(path: 'reports', builder: (c, s) => const ReportsScreen()),
          GoRoute(path: 'blog', builder: (c, s) => const BlogManagementScreen()),
          GoRoute(path: 'new-products', builder: (c, s) => const NewProductsScreen()),
          GoRoute(path: 'my-products', builder: (c, s) => const MyProductsScreen()),
          GoRoute(path: 'selling', builder: (c, s) => const SellingScreen()),
          GoRoute(path: 'buying', builder: (c, s) => const BuyingScreen()),
          GoRoute(path: 'system-logs', builder: (c, s) => const SystemLogsScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
