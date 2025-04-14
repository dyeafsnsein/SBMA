import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'components/header.dart';
import '../../../shared_components/balance_overview.dart';
import '../../../shared_components/goal_overview.dart';
import 'components/period_selector.dart';
import '../../../shared_components/transaction_list.dart';
import '../../../Controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context);
    debugPrint('HomePage rebuilt with totalBalance: ${controller.totalBalance}');

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
                            onNotificationTap: () {
                              context.push('/notification');
                            },
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          BalanceOverview(
                            totalBalance: controller.totalBalance,
                            totalExpense: controller.totalExpense,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100,
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
                            revenueLastWeek: controller.revenueLastWeek,
                            topCategoryLastWeek: controller.topCategoryLastWeek,
                            topCategoryAmountLastWeek: controller.topCategoryAmountLastWeek,
                            topCategoryIconLastWeek: controller.topCategoryIconLastWeek,
                            goalAmount: 10000.0,
                            currentBalance: controller.totalBalance,
                            onTap: () => context.push('/analysis'),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push('/transactions/add-expense');
          },
          backgroundColor: const Color(0xFF202422),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}