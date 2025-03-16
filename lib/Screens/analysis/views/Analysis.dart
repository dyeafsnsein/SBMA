import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'components/analysis_header.dart';
import '../../../shared_components/fl_bar_chart.dart';
import 'components/period_selector_analysis.dart';
import '../../../shared_components/income_expense_summary.dart';
import 'components/targets_section.dart';
import '../../../Controllers/analysis_controller.dart';
import '../../../Models/analysis_model.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalysisController(AnalysisModel()),
      child: Consumer<AnalysisController>(
        builder: (context, controller, child) {
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;

          // Get current period data based on selection
          String currentPeriod = controller.periods[controller.selectedPeriodIndex];
          List<double> expenses = List<double>.from(controller.periodData[currentPeriod]!['expenses']);
          List<double> income = List<double>.from(controller.periodData[currentPeriod]!['income']);
          List<String> labels = List<String>.from(controller.periodData[currentPeriod]!['labels']);

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
                        totalBalance: 7783.00,
                        totalExpense: 1187.40,
                        expensePercentage: 30,
                        expenseLimit: 20000.00,
                        onBackPressed: () => context.go('/'), // Navigate back to Home using GoRouter
                        onNotificationTap: () => context.push('/notification'),
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
                          child: SingleChildScrollView(
                            key: const PageStorageKey('analysis_scroll'),
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PeriodSelector(
                                    periods: controller.periods,
                                    selectedIndex: controller.selectedPeriodIndex,
                                    onPeriodChanged: controller.onPeriodChanged,
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
                                  const IncomeExpenseSummary(
                                    income: 4120.00,
                                    expense: 1187.40,
                                  ),
                                  SizedBox(height: screenHeight * 0.03),
                                  TargetsSection(targets: controller.targets),
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
      ),
    );
  }
}