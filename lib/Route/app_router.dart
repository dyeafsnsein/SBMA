import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared_components/main_container.dart';
import '../Screens/home/views/Home.dart';
import '../Screens/analysis/views/Analysis.dart';
import '../Screens/transactions/views/transaction.dart';
import '../Screens/categories/views/categories.dart';
import '../Screens/quick_analysis/views/QuickAnalysis.dart';
import '../Screens/notification/views/Notification.dart';
import '../Screens/categoryTemplate/views/categoryTemplate.dart';
import '../Screens/login/views/login.dart';
import '../Screens/signup/views/signup.dart';
import '../Screens/login/views/forgot_password.dart';
import '../Screens/profile/views/profile.dart';
import '../Screens/categories/views/components/Add_expense.dart'; // Import AddExpensesPage

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Auth routes (outside shell, no bottom nav)
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    // Main app shell with bottom nav
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainContainerPage(child: child);
      },
      routes: [
        // Home and its sub-routes
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'quick-analysis',
              builder: (context, state) => const QuickAnalysisPage(),
            ),
          ],
        ),

        // Analysis section
        GoRoute(
          path: '/analysis',
          builder: (context, state) => const AnalysisPage(),
        ),

        // Transactions section
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionsPage(),
        ),

        // Categories section and its sub-routes
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoryPage(),
          routes: [
            GoRoute(
              path: 'template/:categoryName/:categoryIcon',
              builder:
                  (context, state) => CategoryTemplatePage(
                    categoryName: state.pathParameters['categoryName']!,
                    categoryIcon: Uri.decodeComponent(
                      state.pathParameters['categoryIcon']!,
                    ),
                  ),
            ),
            GoRoute(
              path: 'add-expense/:categoryName',
              builder: (context, state) {
                final categoryName = state.pathParameters['categoryName']!;
                return AddExpensesPage(
                  categoryName: categoryName,
                ); // Pass categoryName
              },
            ),
          ],
        ),

        // Profile section
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),

    // Standalone routes (outside shell, no bottom nav)
    GoRoute(
      path: '/notification',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationPage(),
    ),
  ],

  // Global redirect for auth
  redirect: (BuildContext context, GoRouterState state) {
    // Add your auth logic here if needed
    return null;
  },
);
