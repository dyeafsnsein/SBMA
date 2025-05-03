import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'components/analysis_header.dart';
import 'components/fl_bar_chart.dart';
import 'components/period_selector_analysis.dart';
import '../../../commons/income_expense_summary.dart';
import 'components/targets_section.dart';
import '../../../Controllers/analysis_controller.dart';
import '../../../Models/savings_goal.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  AnalysisPageState createState() => AnalysisPageState();
}

class AnalysisPageState extends State<AnalysisPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _convertSavingsGoalsToTargets(
      List<SavingsGoal> goals) {
    return goals.map((goal) {
      final progress =
          goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0.0;
      return {
        'name': goal.name,
        'progress': progress.clamp(0.0, 1.0),
        'color': _getColorForGoal(goal.name),
      };
    }).toList();
  }

  Color _getColorForGoal(String name) {
    switch (name.toLowerCase()) {
      case 'travel':
        return const Color(0xFF00FF94);
      case 'car':
        return const Color(0xFF00A3FF);
      case 'new house':
        return const Color(0xFFFFA500);
      case 'wedding':
        return const Color(0xFFFF69B4);
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AnalysisPage: Building');
    return Consumer<AnalysisController>(
      builder: (context, controller, child) {
        debugPrint('AnalysisPage: Consumer builder called');
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        final expensePercentage = controller.totalBalance > 0
            ? (controller.totalExpense / controller.totalBalance * 100).toInt()
            : 0;

        String currentPeriod =
            controller.periods[controller.selectedPeriodIndex];
        final periodData = controller.periodData[currentPeriod] ??
            {
              'expenses': <double>[],
              'income': <double>[],
              'labels': <String>[],
            };
        List<double> expenses =
            List<double>.from(periodData['expenses'] as List? ?? []);
        List<double> income =
            List<double>.from(periodData['income'] as List? ?? []);
        List<String> labels =
            List<String>.from(periodData['labels'] as List? ?? []);

        final targets = _convertSavingsGoalsToTargets(controller.savingsGoals);

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
                    AnalysisHeader(
                      totalBalance: controller.totalBalance,
                      totalExpense: controller.totalExpense,
                      expensePercentage: expensePercentage,
                      onBackPressed: () {
                        if (!context.mounted) return;
                        context.go('/');
                      },
                      onNotificationTap: () {
                        if (!context.mounted) return;
                        context.push('/notification');
                      },
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1FFF3),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: controller.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : controller.errorMessage != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          controller.errorMessage!,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            color: Colors.red,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            controller.retryLoading();
                                          },
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  )
                                : SingleChildScrollView(
                                    key:
                                        const PageStorageKey('analysis_scroll'),
                                    physics: const BouncingScrollPhysics(),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(screenWidth * 0.04),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          PeriodSelector(
                                            periods: controller.periods,
                                            selectedIndex:
                                                controller.selectedPeriodIndex,
                                            onPeriodChanged:
                                                controller.onPeriodChanged,
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          FadeTransition(
                                            opacity: fadeAnimation,
                                            child: FlBarChart(
                                              expenses: expenses,
                                              income: income,
                                              labels: labels,
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          IncomeExpenseSummary(
                                            income: controller.totalIncome,
                                            expense: controller.totalExpense,
                                          ),
                                          SizedBox(height: screenHeight * 0.03),
                                          _buildCategoryBreakdown(
                                              controller.categoryBreakdown,
                                              screenWidth),
                                          SizedBox(height: screenHeight * 0.03),
                                          TargetsSection(targets: targets),
                                          SizedBox(height: screenHeight * 0.1),
                                        ],
                                      ),
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
    );
  }

  Widget _buildCategoryBreakdown(
      Map<String, double> breakdown, double screenWidth) {
    if (breakdown.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending by Category',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF202422),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: const Color(0xFF202422),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: breakdown.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
