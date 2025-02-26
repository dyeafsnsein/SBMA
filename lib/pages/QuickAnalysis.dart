import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/quick_analysis_header.dart';
import 'components/goal_overview.dart';
import 'components/fl_bar_chart.dart';
import 'components/transaction_list.dart';
import 'components/bottom_nav_bar.dart';
import 'Home.dart';

class QuickAnalysis extends StatefulWidget {
  const QuickAnalysis({Key? key}) : super(key: key);

  @override
  State<QuickAnalysis> createState() => _QuickAnalysisState();
}

class _QuickAnalysisState extends State<QuickAnalysis> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _transactions = [
    {
      'icon': 'lib/pages/assets/Salary.png',
      'title': 'Salary',
      'time': '18:27 - April 30',
      'category': 'Monthly',
      'amount': '\$4,000.00',
    },
    // ... other transactions
  ];

  final List<String> _iconPaths = [
    'lib/pages/assets/Home.png',
    'lib/pages/assets/Analysis.png',
    'lib/pages/assets/Transactions.png',
    'lib/pages/assets/Categories.png',
    'lib/pages/assets/Profile.png',
  ];

  final List<double> _expenses = [6, 10, 20, 7];
  final List<double> _income = [6, 8, 12, 6];
  final List<String> _chartLabels = ['1st Week', '2nd Week', '3rd Week', '4th Week'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double paddingTop = MediaQuery.of(context).padding.top;
    final double height = screenSize.height;
    final double width = screenSize.width;

    // Calculate responsive dimensions
    final double topSectionHeight = height * 0.32; // 32% of screen height
    final double bottomSectionHeight = height * 0.68; // 68% of screen height
    final double horizontalPadding = width * 0.06; // 6% of screen width
    final double verticalPadding = height * 0.02; // 2% of screen height
    final double chartHeight = height * 0.25; // 25% of screen height
    final double spaceBetween = height * 0.02; // 2% of screen height

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
                              // Handle notification tap
                            },
                          ),
                          GoalOverview(
                            goalIcon: 'lib/pages/assets/Car.png',
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
                          Flexible(
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                iconPaths: _iconPaths,
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
