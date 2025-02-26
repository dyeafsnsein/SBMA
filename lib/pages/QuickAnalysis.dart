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
                  flex: 38,
                  child: Container(
                    color: const Color(0xFF202422),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 60, 25, 10),
                      child: Column(
                        children: [
                          QuickAnalysisHeader(
                            onBackPressed: () => Navigator.pop(context),
                            onNotificationTap: () {
                              // Handle notification tap
                            },
                          ),
                          const SizedBox(height: 20),
                          GoalOverview(
                            goalIcon: 'lib/pages/assets/Car.png',
                            goalText: 'Savings On Goals',
                            revenueLastWeek: 4000.00,
                            foodLastWeek: 100.00,
                            onTap: () {}, // Add tap handler if needed
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 84,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          FlBarChart(
                            expenses: _expenses,
                            income: _income,
                            labels: _chartLabels,
                          ),
                          const SizedBox(height: 20),
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
