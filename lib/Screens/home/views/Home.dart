import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:test_app/commons/balance_overview.dart';
import 'components/header.dart';
import 'components/goal_overview.dart';
import '../../../commons/transaction_list.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Controllers/savings_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context);
    final savingsController = Provider.of<SavingsController>(context);
    debugPrint(
        'HomePage rebuilt with totalBalance: ${homeController.totalBalance}');

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF202422),
        body: SafeArea(
          bottom: false, // Let the container handle bottom padding
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Header(
                      onNotificationTap: () {
                        context.push('/notification');
                      },
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    BalanceOverview(
                      totalBalance: homeController.totalBalance,
                      totalExpense: homeController.totalExpense,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.06,
                        right: screenWidth * 0.06,
                        top: screenWidth * 0.06,
                        // Add bottom padding to account for system navigation
                      ),
                      child: Column(
                        children: [
                          // Check if there's an active goal
                          savingsController.activeGoal != null &&
                                  savingsController.activeGoal!.id != 'none'
                              ? GoalOverview(
                                  goalIcon:
                                      savingsController.activeGoal!.icon,
                                  goalText:
                                      savingsController.activeGoal!.name,
                                  revenueLastWeek:
                                      homeController.revenueLastWeek,
                                  topCategoryLastWeek:
                                      homeController.topCategoryLastWeek,
                                  topCategoryAmountLastWeek: homeController
                                      .topCategoryAmountLastWeek,
                                  topCategoryIconLastWeek: homeController
                                      .topCategoryIconLastWeek,
                                  goalAmount: savingsController
                                      .activeGoal!.targetAmount,
                                  currentBalance: savingsController
                                      .activeGoal!.currentAmount,
                                  onTap: () => context.push('/analysis'),
                                )
                              : GestureDetector(
                                  onTap: () => context.push('/analysis'),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 109, 42, 42),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'No Active Goal - Tap to Analyze',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(height: screenHeight * 0.02),
                          Expanded(
                            child: TransactionList(
                                transactions: homeController.transactions),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
