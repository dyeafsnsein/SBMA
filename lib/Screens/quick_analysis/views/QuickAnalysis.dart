import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/quick_analysis_header.dart';
import '../../home/views/components/goal_overview.dart';
import '../../../shared_components/fl_bar_chart.dart';
import '../../../shared_components/transaction_list.dart';
import '../../../shared_components/bottom_nav_bar.dart';

class QuickAnalysis extends StatefulWidget {
  const QuickAnalysis({Key? key}) : super(key: key);

  @override
  State<QuickAnalysis> createState() => _QuickAnalysisState();
}

class _QuickAnalysisState extends State<QuickAnalysis> {
  final List<Map<String, String>> _transactions = [
    {
      'icon': 'lib/assets/Salary.png',
      'title': 'Salary',
      'time': '18:27 - April 30',
      'category': 'Monthly',
      'amount': '\$4,000.00',
    },
  ];

  final List<String> _iconPaths = [
    'lib/assets/Home.png',
    'lib/assets/Analysis.png',
    'lib/assets/Transactions.png',
    'lib/assets/Categories.png',
    'lib/assets/Profile.png',
  ];

  final List<double> _expenses = [6.0, 10.0, 20.0, 7.0];
  final List<double> _income = [6.0, 8.0, 12.0, 6.0];
  final List<String> _chartLabels = ['1st Week', '2nd Week', '3rd Week', '4th Week'];

  @override
  Widget build(BuildContext context) {
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
                            onNotificationTap: () {},
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
                              expenses: _expenses,
                              income: _income,
                              labels: _chartLabels,
                            ),
                          ),
                          SizedBox(height: spaceBetween),
                          Expanded(
                            child: TransactionList(
                              transactions: _transactions,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavBar(
                iconPaths: _iconPaths,
                selectedIndex: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
