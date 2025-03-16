import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:go_router/go_router.dart';
import 'components/header.dart';
import '../../../shared_components/balance_overview.dart';
import '../../../shared_components/progress_bar.dart';
import '../../../shared_components/goal_overview.dart';
import 'components/period_selector.dart';
import '../../../shared_components/transaction_list.dart';
import '../../../Route/app_router.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Models/home_model.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(HomeModel()),
      child: Consumer<HomeController>(
        builder: (context, controller, child) {
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFF202422),
              body: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        flex: 36,
                        child: Container(
                          color: const Color(0xFF202422),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06,
                              vertical: screenHeight * 0.06,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Header(
                                  onNotificationTap: () {context.push('/notification');
                                  
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                BalanceOverview(
                                  totalBalance: 7783.00,
                                  totalExpense: 1187.40,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                ProgressBar(progress: 0.3, goalAmount: 20000.00),
                                SizedBox(height: screenHeight * 0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'lib/assets/Check.png',
                                      width: screenWidth * 0.03,
                                      height: screenWidth * 0.03,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text(
                                      '30% of your expenses, looks good.',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: screenWidth * 0.037,
                                        color: const Color(0xFFFCFCFC),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 64,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1FFF3),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.05),
                            child: Column(
                              children: [
                                GoalOverview(
                                  goalIcon: 'lib/assets/Car.png',
                                  goalText: 'Savings On Goals',
                                  revenueLastWeek: 4000.00,
                                  foodLastWeek: 100.00,
                             onTap: () => context.push('/quick-analysis'),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                PeriodSelector(
                                  periods: controller.periods,
                                  selectedPeriodIndex: controller.selectedPeriodIndex,
                                  onPeriodTapped: controller.onPeriodTapped,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Expanded(
                                  child: TransactionList(transactions: controller.transactions),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}