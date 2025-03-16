import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/quick_analysis_header.dart';
import '../../../shared_components/goal_overview.dart';
import '../../../shared_components/fl_bar_chart.dart';
import '../../../shared_components/transaction_list.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/quick_analysis_controller.dart';
import '../../../Models/quick_analysis_model.dart';
import '../../../Route/app_router.dart';

@RoutePage()
class QuickAnalysisPage extends StatelessWidget {
  const QuickAnalysisPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuickAnalysisController(QuickAnalysisModel()),
      child: Consumer<QuickAnalysisController>(
        builder: (context, controller, child) {
          final Size screenSize = MediaQuery.of(context).size;
          final double paddingTop = MediaQuery.of(context).padding.top;
          final double height = screenSize.height;
          final double width = screenSize.width;

          final double topSectionHeight = height * 0.32;
          final double horizontalPadding = width * 0.06;
          final double verticalPadding = height * 0.02;
          final double spaceBetween = height * 0.02;

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
                      SizedBox(
                        height: topSectionHeight,
                        child: Container(
                          color: const Color(0xFF202422),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              paddingTop + verticalPadding,
                              horizontalPadding,
                              verticalPadding,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                QuickAnalysisHeader(
                                  onBackPressed: () => Navigator.pop(context),
                                  onNotificationTap: () {
                                    
                                  },
                                ),
                                GoalOverview(
                                  goalIcon: 'lib/assets/Car.png',
                                  goalText: 'Savings On Goals',
                                  revenueLastWeek: 4000.00,
                                  foodLastWeek: 100.00,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
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
                          child: Padding(
                            padding: EdgeInsets.all(horizontalPadding),
                            child: Column(
                              children: [
                                // Fixed height container for the chart instead of Flexible
                                SizedBox(
                                  height: height * 0.28, // Adjust this value as needed
                                  child: FlBarChart(
                                    expenses: controller.expenses,
                                    income: controller.income,
                                    labels: controller.chartLabels,
                                  ),
                                ),
                                SizedBox(height: spaceBetween),
                                Expanded(
                                  child: TransactionList(
                                    transactions: controller.transactions,
                                  ),
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