import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../shared_components/bottom_nav_bar.dart';
import '../Route/app_router.dart';

@RoutePage()
class MainContainerPage extends StatelessWidget {
  const MainContainerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        AnalysisRoute(),
        TransactionsRoute(),
        CategoryRoute(),
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        // Check if current route is QuickAnalysis or Notification (no tab selected)
        final isQuickAnalysis = currentRouteIsQuickAnalysis(context);
        final isNotification = currentRouteIsNotification(context);

        return Scaffold(
          extendBody: true,
          body: child,
          bottomNavigationBar: BottomNavBar(
            iconPaths: [
              'lib/assets/Home.png',
              'lib/assets/Analysis.png',
              'lib/assets/Transactions.png',
              'lib/assets/Categories.png',
              'lib/assets/Profile.png',
            ],
            selectedIndex:
                (isQuickAnalysis || isNotification) ? -1 : tabsRouter.activeIndex,
            onTap: (index) {
              if (isQuickAnalysis || isNotification) {
                context.router.pop(); // pop back from quick analysis or notification first
              }
              tabsRouter.setActiveIndex(index);
            },
          ),
        );
      },
    );
  }

  bool currentRouteIsQuickAnalysis(BuildContext context) {
    return context.router.topRoute.name == QuickAnalysisRoute.name;
  }

  bool currentRouteIsNotification(BuildContext context) {
    return context.router.topRoute.name == NotificationRoute.name;
  }
}
