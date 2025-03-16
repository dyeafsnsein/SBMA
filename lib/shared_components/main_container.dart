import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bottom_nav_bar.dart';

class MainContainerPage extends StatelessWidget {
  final Widget child;

  const MainContainerPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: BottomNavBar(
        iconPaths: const [
          'lib/assets/Home.png',
          'lib/assets/Analysis.png',
          'lib/assets/Transactions.png',
          'lib/assets/Categories.png',
          'lib/assets/Profile.png',
        ],
        selectedIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    
    // Define route patterns
    final patterns = [
      [r'^/$', r'^/quick-analysis'], // Home routes
      [r'^/analysis'], // Analysis routes
      [r'^/transactions'], // Transaction routes
      [r'^/categories'], // Category routes
      [r'^/profile'], // Profile routes
      [r'^/profile', r'^/profile/edit-profile'], // Profile routes with edit profile

    ];
    
    // Find matching pattern index
    for (var i = 0; i < patterns.length; i++) {
      if (patterns[i].any((pattern) => 
          RegExp(pattern).hasMatch(location))) {
        return i;
      }
    }
    
    return 0; // Default to home
  }

  void _onItemTapped(int index, BuildContext context) {
    final routes = [
      '/',
      '/analysis',
      '/transactions', 
      '/categories',
      '/profile',
    ];

    if (index >= 0 && index < routes.length) {
      context.go(routes[index]);
    }
  }
}