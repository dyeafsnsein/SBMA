import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
// For debugPrint
import '../commons/main_container.dart';
import '../Screens/home/views/home.dart';
import '../Screens/analysis/views/Analysis.dart';
import '../Screens/transactions/views/transaction.dart';
import '../Screens/categories/views/categories.dart';
import '../Screens/notification/views/Notification1.dart';
import '../Screens/Auth/views/login.dart';
import '../Screens/Auth/views/signup.dart';
import '../Screens/Auth/views/forgot_password.dart';
import '../Screens/profile/views/profile.dart';
import '../Screens/profile/views/editprofile.dart';
import '../Screens/saving/saving.dart';
import '../Screens/saving/saving_analysis.dart';
import '../Screens/set_balance/views/set_balance.dart';
import '../Screens/Auth/views/LaunchPage.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/', // LaunchPage is at root path '/'
  routes: [
    // Auth routes (outside shell, no bottom nav)
    GoRoute(
      path: '/',
      builder: (context, state) => const LaunchPage(),
    ),
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
      routes: [        // Home and its sub-routes
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
          routes: [
         
          ],
        ),
   GoRoute(
              path: '/analysis',
              builder: (context, state) => const AnalysisPage(),
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
          routes: [],
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
  ],  // Global redirect for auth and balance setup
  redirect: (BuildContext context, GoRouterState state) async {
    // Current location for debugging
    debugPrint("Router: Current route: ${state.matchedLocation}");
    
    // Define routes that don't require authentication checks
    final bool isOnAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/forgot-password' ||
        state.matchedLocation == '/';

    final bool isOnSetBalanceRoute = state.matchedLocation == '/set-balance';

    // Check authentication state
    User? user = FirebaseAuth.instance.currentUser;
    bool isLoggedIn = user != null;
    
    debugPrint("Router: User logged in: $isLoggedIn, userId: ${user?.uid}");
    
    // CRITICAL: Skip all redirects for set-balance page to ensure the navigation flow works
    if (isOnSetBalanceRoute) {
      debugPrint("Router: Allowing direct access to set-balance page");
      return null; // Allow direct access without redirect
    }
    
    // If not logged in and not on an auth route, redirect to root/launch page
    if (!isLoggedIn && !isOnAuthRoute) {
      debugPrint("Router: Redirecting unauthenticated user to / (launch page)");
      return '/';
    }
    
    // If logged in and on an auth route, redirect to home
    if (isLoggedIn && isOnAuthRoute) {
      debugPrint("Router: Redirecting authenticated user to /home");
      return '/home';
    }

    // Default case: no redirect needed
    debugPrint("Router: No redirection needed for ${state.matchedLocation}");
    return null;
  },
);
