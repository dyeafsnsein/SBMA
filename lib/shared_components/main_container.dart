// MainContainerPage.dart
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
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

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
            selectedIndex: tabsRouter.activeIndex,
            onTap: (index) {
              tabsRouter.setActiveIndex(index);
            },
          ),
        );
      },
    );
  }
}

