import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/Screens/help/views/HelpCenter.dart';
import 'package:test_app/Screens/security/views/FingerprintAddSuccess.dart';
import 'package:test_app/Screens/security/views/FingerprintDeleteSuccess.dart';
import 'package:test_app/Screens/settings/views/DeleteAccount.dart';
import 'package:test_app/Screens/settings/views/PasswordChangeSuccess.dart';
import 'package:test_app/Screens/settings/views/Settings.dart';
import 'package:test_app/Screens/settings/views/NotificationSettings.dart';
import 'package:test_app/Screens/settings/views/PasswordSettings.dart';
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
import '../Screens/profile/views/editprofile.dart';
import '../Screens/security/views/SecurityEdit.dart';
import '../Screens/security/views/ChangePin.dart';
import '../Screens/security/views/PinChangeSuccess.dart';
import '../Screens/security/views/Fingerprint.dart';
import '../Screens/security/views/FingerprintActionPage.dart';
import '../Screens/security/views/AddFingerprint.dart';
import '../Screens/security/views/TermsAndConditions.dart';
import '../Screens/categories/views/components/Add_expense.dart';
import '../Screens/saving/saving.dart';
import '../Screens/saving/saving_analysis.dart';
import '../Screens/set_balance/views/set_balance.dart';
import '../services/auth_service.dart'; // Add this import

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    // Auth routes (outside shell, no bottom nav)
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
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
    GoRoute(
      path: '/success3',
      builder: (context, state) => const PasswordChangeSuccess(),
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
                categoryIcon: Uri.decodeComponent(
                  state.pathParameters['categoryIcon']!,
                ),
              ),
              routes: [
                GoRoute(
                  path: 'add-expense',
                  builder: (context, state) {
                    final categoryName = state.pathParameters['categoryName']!;
                    final addNewExpense =
                        state.extra as Function(Map<String, String>);
                    return AddExpensesPage(
                      categoryName: categoryName,
                      onSave: addNewExpense,
                    );
                  },
                ),
              ],
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
            final args = state.extra as Map<String, String>;
            print('Received args: $args');
            return SavingsAnalysisPage(
              categoryName: args['categoryName']!,
              iconPath: args['iconPath']!,
            );
          },
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
              routes: [
                GoRoute(
                  path: 'notification-settings',
                  builder: (context, state) => const NotificationSettings(),
                ),
                GoRoute(
                  path: 'password-settings',
                  builder: (context, state) => const PasswordSettings(),
                ),
                GoRoute(
                  path: 'delete-account',
                  builder: (context, state) => const DeleteAccount(),
                ),
              ],
            ),
            GoRoute(
              path: 'help-center',
              builder: (context, state) => const HelpCenter(),
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
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final bool isOnAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/forgot-password';
    final bool isOnSetBalanceRoute = state.matchedLocation == '/set-balance';

    // If not logged in and not on an auth route, redirect to login
    if (!isLoggedIn && !isOnAuthRoute) {
      return '/login';
    }

    // If logged in and on an auth route, redirect to root (will handle further redirects)
    if (isLoggedIn && isOnAuthRoute) {
      return '/';
    }

    // If logged in, check if the user has set their balance
    if (isLoggedIn) {
      final authService = AuthService();
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await authService.getUserData(user.uid);

      if (userData == null) {
        // If user data doesn't exist, redirect to login (shouldn't happen after signup)
        return '/login';
      }

      final hasSetBalance = userData['hasSetBalance'] ?? false;
      // If balance not set and not on set-balance route, redirect to set-balance
      if (!hasSetBalance && !isOnSetBalanceRoute) {
        return '/set-balance';
      }

      // If balance is set and on root, stay on root (or proceed to intended route)
      if (hasSetBalance && state.matchedLocation == '/') {
        return null; // Let the user proceed to the home page
      }
    }

    return null; // No redirect needed
  },
);