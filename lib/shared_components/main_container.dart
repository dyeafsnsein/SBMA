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
        HomeRoute(), // Use the correct route class
        AnalysisRoute(),
        TransactionsRoute(),
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavBar(
            iconPaths: [
              'lib/assets/Home.png',
              'lib/assets/Analysis.png',
              'lib/assets/Transactions.png',
              'lib/assets/Categories.png',
              'lib/assets/Profile.png',
            ],
            selectedIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
          ),
        );
      },
    );
  }
}
