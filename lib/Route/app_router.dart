import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../commons/main_container.dart';
import '../Screens/home/views/home.dart';
import '../Screens/analysis/views/Analysis.dart';
import '../Screens/transactions/views/transaction.dart';
import '../Screens/categories/views/categories.dart';
import '../Screens/notification/views/Notification.dart';
import '../Screens/login/views/login.dart';
import '../Screens/signup/views/signup.dart';
import '../Screens/login/views/forgot_password.dart';
import '../Screens/profile/views/profile.dart';
import '../Screens/profile/views/editprofile.dart';
import '../Screens/saving/saving.dart';
import '../Screens/saving/saving_analysis.dart';
import '../Screens/set_balance/views/set_balance.dart';
import '../services/auth_service.dart';
import '../Screens/transactions/views/add_expenses_page.dart';
import '../Screens/transactions/views/add_income_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    // Auth routes (outside shell, no bottom nav)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => ForgotPasswordPage(),
    ),

    GoRoute(
      path: '/set-balance',
      builder: (context, state) => const SetBalancePage(),
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
              path: 'analysis',
              builder: (context, state) => const AnalysisPage(),
            ),
          ],
        ),

        // Savings section
        GoRoute(
          path: '/savings',
          builder: (context, state) => const SavingsPage(),
        ),
        GoRoute(
          path: '/savings-analysis',
          builder: (context, state) {
            final args = state.extra as Map<String, String>?;
            if (args == null ||
                !args.containsKey('categoryName') ||
                !args.containsKey('iconPath') ||
                !args.containsKey('goalId')) {
              throw const FormatException(
                  'Missing required arguments for SavingsAnalysisPage');
            }
            return SavingsAnalysisPage(
              categoryName: args['categoryName']!,
              iconPath: args['iconPath']!,
              goalId: args['goalId']!,
            );
          },
        ),

        // Transactions section
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionsPage(),
          routes: [
            GoRoute(
              path: 'add-expense',
              builder: (context, state) {
                final addNewExpense =
                    state.extra as Function(Map<String, String>);
                return TransactionAddExpensePage(
                  onSave: addNewExpense,
                );
              },
            ),
            GoRoute(
              path: 'add-income',
              builder: (context, state) {
                final addNewIncome =
                    state.extra as Function(Map<String, String>);
                return TransactionAddIncomePage(
                  onSave: addNewIncome,
                );
              },
            ),
          ],
        ),

        // Categories section and its sub-routes
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoryPage(),
          routes: const [],
        ),

        // Profile section and its sub-routes
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
          routes: [
            GoRoute(
              path: 'edit-profile',
              builder: (context, state) => const EditProfilePage(),
            ),
          ],
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

  // Global redirect for auth and balance setup
  redirect: (BuildContext context, GoRouterState state) async {
    // Define routes that don't require authentication checks
    final bool isOnAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/forgot-password';
    final bool isOnSetBalanceRoute = state.matchedLocation == '/set-balance';
    final bool isOnSuccessRoute = state.matchedLocation == '/success3';

    // Allow navigation to success route without interference
    if (isOnSuccessRoute) {
      debugPrint('Redirect: Allowing navigation to /success3');
      return null;
    }

    // Check authentication state
    User? user = FirebaseAuth.instance.currentUser;
    bool isLoggedIn = user != null;

    debugPrint('Redirect: Checking auth state - isLoggedIn=$isLoggedIn, '
        'location=${state.matchedLocation}, '
        'isOnAuthRoute=$isOnAuthRoute, '
        'isOnSetBalanceRoute=$isOnSetBalanceRoute');

    // If not logged in and not on an auth route, redirect to login
    if (!isLoggedIn && !isOnAuthRoute) {
      debugPrint(
          'Redirect: Not logged in and not on auth route, redirecting to /login');
      return '/login';
    }

    // If logged in and on an auth route, redirect to root
    if (isLoggedIn && isOnAuthRoute) {
      debugPrint('Redirect: Logged in and on auth route, redirecting to /');
      return '/';
    }

    // Only check for balance setup if user is logged in and not on an auth route
    if (isLoggedIn && !isOnAuthRoute) {
      final authService = AuthService();

      // Fetch user data
      Map<String, dynamic>? userData;
      try {
        userData = await authService.getUserData(user.uid);
      } catch (e) {
        debugPrint('Redirect: Error fetching user data: $e');
        // Sign out and redirect to login if there's an error
        await FirebaseAuth.instance.signOut();
        await authService.signOut();
        debugPrint('Redirect: Signed out due to error, redirecting to /login');
        return '/login';
      }

      // If user data is null, sign out and redirect to login
      if (userData == null) {
        debugPrint(
            'Redirect: User data is null, signing out and redirecting to /login');
        await FirebaseAuth.instance.signOut();
        await authService.signOut();
        debugPrint('Redirect: Signed out, redirecting to /login');
        return '/login';
      }

      final hasSetBalance = userData['hasSetBalance'] ?? false;

      // If balance not set and not on set-balance route, redirect to set-balance
      if (!hasSetBalance && !isOnSetBalanceRoute) {
        debugPrint('Redirect: Balance not set, redirecting to /set-balance');
        return '/set-balance';
      }
    }

    // Default case: no redirect needed
    debugPrint(
        'Redirect: No redirect needed, proceeding to ${state.matchedLocation}');
    return null;
  },
);
