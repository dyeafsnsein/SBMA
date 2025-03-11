import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../Route/app_router.dart';
import 'bottom_nav_bar.dart';

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
        
        // Check if the current route is QuickAnalysis
        final isQuickAnalysis = context.router.current.name == 'QuickAnalysisRoute';
        
        return Scaffold(
          extendBody: true,
          body: child,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 0, left: 0, right: 0),
            child: BottomNavBar(
              iconPaths: [
                'lib/assets/Home.png',
                'lib/assets/Analysis.png',
                'lib/assets/Transactions.png',
                'lib/assets/Categories.png',
                'lib/assets/Profile.png',
              ],
              // If we're on QuickAnalysis, don't highlight any tab
              selectedIndex: isQuickAnalysis ? -1 : tabsRouter.activeIndex,
              onTap: (index) {
                if (isQuickAnalysis) {
                  // If we're on QuickAnalysis, navigate back to the main tab
                  context.router.navigate(const HomeRoute());
                }
                tabsRouter.setActiveIndex(index);
              },
            ),
          ),
        );
      },
    );
  }
}
