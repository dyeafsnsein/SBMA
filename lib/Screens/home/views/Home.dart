import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:test_app/commons/balance_overview.dart';
import 'components/header.dart';
import '../../../commons/goal_overview.dart';
import '../../../commons/transaction_list.dart';
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
                          // Check if there's an active goal
                          controller.activeGoal != null
                              ? GoalOverview(
                                  goalIcon: controller.activeGoal!.icon,
                                  goalText: controller.activeGoal!.name,
                                  revenueLastWeek: controller.revenueLastWeek,
                                  topCategoryLastWeek:
                                      controller.topCategoryLastWeek,
                                  topCategoryAmountLastWeek:
                                      controller.topCategoryAmountLastWeek,
                                  topCategoryIconLastWeek:
                                      controller.topCategoryIconLastWeek,
                                  goalAmount: controller.activeGoal!.targetAmount,
                                  currentBalance:
                                      controller.activeGoal!.currentAmount,
                                  onTap: () => context.push('/analysis'),
                                )
                              : GestureDetector(
                                  onTap: () => context.push('/analysis'),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 109, 42, 42),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                  
                                  ),
                                ),
                          SizedBox(height: screenHeight * 0.02),
                          Expanded(
                            child: TransactionList(
                                transactions: controller.transactions),
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