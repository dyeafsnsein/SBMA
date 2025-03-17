import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/Screens/security/views/FingerprintAddSuccess.dart';
import 'package:test_app/Screens/security/views/FingerprintDeleteSuccess.dart';
import 'package:test_app/Screens/settings/views/Settings.dart';
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
import '../Screens/profile/views/editprofile.dart'; // Corrected file name
import '../Screens/security/views/SecurityEdit.dart';
import '../Screens/security/views/ChangePin.dart';
import '../Screens/security/views/PinChangeSuccess.dart';
import '../Screens/security/views/Fingerprint.dart';
import '../Screens/security/views/FingerprintActionPage.dart';
import '../Screens/security/views/AddFingerprint.dart';
import '../Screens/security/views/TermsAndConditions.dart';
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
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
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) => const PinChangeSuccess(),
    ),
    GoRoute(
      path: '/delete-success',
      builder: (context, state) => const FingerprintDeleteSuccess(),
    ),
    GoRoute(
      path: '/success2',
      builder: (context, state) => const FingerprintAddSuccess(),
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
              builder: (context, state) => CategoryTemplatePage(
                categoryName: state.pathParameters['categoryName']!,
                categoryIcon: Uri.decodeComponent(state.pathParameters['categoryIcon']!),
              ),
            ),
          ],
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
            
            GoRoute(
              path: 'security-edit',
              builder: (context, state) => const SecurityEdit(),
              routes: [
                GoRoute(
                  path: 'change-pin',
                  builder: (context, state) => const ChangePin(),
                  routes: [
                    GoRoute(
                      path: 'success',
                      builder: (context, state) => const PinChangeSuccess(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'fingerprint',
                  builder: (context, state) => const Fingerprint(),
                  routes: [
                    GoRoute(
                      path: 'action/:fingerprintName',
                      builder: (context, state) => FingerprintActionPage(
                        fingerprintName: state.pathParameters['fingerprintName']!,
                      ),
                    ),
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const AddFingerprint(),
                    ),
                  ],
                ),
                    GoRoute(
                  path: 'terms-and-conditions',
                  builder: (context, state) => const TermsAndConditions(),
                ),
              ],
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const Settings(),
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
  
  // Global redirect for auth
  redirect: (BuildContext context, GoRouterState state) {
    // Add your auth logic here if needed
    // Example:
    // final bool isLoggedIn = AuthService.isLoggedIn;
    // final bool isAuthRoute = state.location.startsWith('/login') ||
    //     state.location.startsWith('/signup') ||
    //     state.location.startsWith('/forgot-password');
    
    // if (!isLoggedIn && !isAuthRoute) {
    //   return '/login';
    // }
    // if (isLoggedIn && isAuthRoute) {
    //   return '/';
    // }
    
    return null;
  },
);