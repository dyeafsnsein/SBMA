import 'package:auto_route/auto_route.dart';
import '../Screens/home/views/Home.dart';
import '../Screens/analysis/views/Analysis.dart';
import '../Screens/transactions/views/transaction.dart';
import '../Screens/categories/views/categories.dart';
import '../Screens/login/views/login.dart';
import '../Screens/signup/views/signup.dart';
import '../Screens/login/views/forgot_password.dart';
import '../Screens/quick_analysis/views/QuickAnalysis.dart';
import '../Screens/calendar/views/Calendar.dart';
import '../Screens/notification/views/Notification.dart';
import '../Screens/search/views/Search.dart';
import '../shared_components/main_container.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: MainContainerRoute.page,
          initial: true,
          children: [
            AutoRoute(path: 'home', page: HomeRoute.page, initial: true),
            AutoRoute(path: 'analysis', page: AnalysisRoute.page),
            AutoRoute(path: 'transactions', page: TransactionsRoute.page),
            AutoRoute(path: 'categories', page: CategoryRoute.page),
            // QuickAnalysis as a child route of MainContainer
            AutoRoute(path: 'quick-analysis', page: QuickAnalysisRoute.page),
          ],
        ),
        AutoRoute(path: '/login', page: LoginRoute.page),
        AutoRoute(path: '/signup', page: SignupRoute.page),
        AutoRoute(path: '/forgot-password', page: ForgotPasswordRoute.page),
        AutoRoute(path: '/notification', page: NotificationRoute.page),
      ];
}
