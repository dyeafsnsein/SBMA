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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    
    // Force a refresh of the data when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeController = Provider.of<HomeController>(context, listen: false);
      await homeController.refreshData();
      
      // If we're mounted, trigger a rebuild to ensure the balance is displayed
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context);
    final savingsController = Provider.of<SavingsController>(context);
    debugPrint(
        'HomePage rebuilt with totalBalance: ${homeController.totalBalance}');

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                child: RefreshIndicator(
                  onRefresh: () async {
                    await homeController.refreshData();
                  },
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
                        ),
                        child: Column(
                          children: [
                            GoalOverview(
                              goalIcon: savingsController.activeGoal?.icon ?? 'lib/assets/More.png',
                              goalText: savingsController.activeGoal?.name ?? 'No Active Goal',
                              revenueLastWeek: homeController.revenueLastWeek,
                              topCategoryLastWeek: homeController.topCategoryLastWeek,
                              topCategoryAmountLastWeek: homeController.topCategoryAmountLastWeek,
                              topCategoryIconLastWeek: homeController.topCategoryIconLastWeek,
                              goalAmount: savingsController.activeGoal?.targetAmount ?? 0.0,
                              currentBalance: savingsController.activeGoal?.currentAmount ?? 0.0,
                              onTap: () => context.push('/analysis'),
                              hasActiveGoal: savingsController.activeGoal != null && 
                                          savingsController.activeGoal!.id != 'none',
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Expanded(
                              child: TransactionList(
                                transactions: homeController.transactions,
                                isHomePage: true,
                              ),
                            ),
                          ],
                        ),
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
