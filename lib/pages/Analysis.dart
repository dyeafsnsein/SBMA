import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/balance_overview.dart';
import 'components/progress_bar.dart';
import 'components/fl_bar_chart.dart';
import 'components/bottom_nav_bar.dart';
import 'Notification.dart';

class Analysis extends StatefulWidget {
  const Analysis({Key? key}) : super(key: key);

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  final List<String> _iconPaths = [
    'lib/pages/assets/Home.png',
    'lib/pages/assets/Analysis.png',
    'lib/pages/assets/Transactions.png',
    'lib/pages/assets/Categories.png',
    'lib/pages/assets/Profile.png',
  ];

  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'Year'];
  int _selectedPeriodIndex = 0;

  final List<double> _expenses = [5, 3, 4, 2, 6, 3, 4];
  final List<double> _income = [3, 5, 2, 6, 2, 1, 3];
  final List<String> _chartLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<Map<String, dynamic>> _targets = [
    {
      'name': 'Travel',
      'progress': 0.3,
    },
    {
      'name': 'Car',
      'progress': 0.5,
    },
  ];

  void _onPeriodTapped(int index) {
    setState(() {
      _selectedPeriodIndex = index;
    });
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF202422),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriodIndex == index;
          return GestureDetector(
            onTap: () => _onPeriodTapped(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                _periods[index],
                style: TextStyle(
                  color: isSelected ? const Color(0xFF202422) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildIncomeExpense({
    required String icon,
    required String title,
    required String amount,
    required Color color,
    required double screenWidth,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          icon,
          width: screenWidth * 0.06,
          height: screenWidth * 0.06,
          color: color,
        ),
        SizedBox(height: screenWidth * 0.01),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetItem({
    required String name,
    required double progress,
    required double screenWidth,
  }) {
    return Container(
      width: screenWidth * 0.4,
      height: screenWidth * 0.4,
      decoration: BoxDecoration(
        color: const Color(0xFF202422),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: screenWidth * 0.25,
                height: screenWidth * 0.25,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF94)),
                  strokeWidth: 8,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Container(
                  color: const Color(0xFF202422),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.06,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: screenWidth * 0.06,
                            ),
                          ),
                          Text(
                            'Analysis',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NotificationPage()),
                              );
                            },
                            child: Container(
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.08,
                              decoration: BoxDecoration(
                                color: const Color(0xFF050505),
                                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                              ),
                              child: Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: screenWidth * 0.05,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      BalanceOverview(
                        totalBalance: 7783.00,
                        totalExpense: 1187.40,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ProgressBar(progress: 0.3, goalAmount: 20000.00),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/pages/assets/Check.png',
                            width: screenWidth * 0.03,
                            height: screenWidth * 0.03,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            '30% Of Your Expenses, Looks Good.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.035,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
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
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPeriodSelector(),
                            SizedBox(height: screenHeight * 0.02),
                            FlBarChart(
                              expenses: _expenses,
                              income: _income,
                              labels: _chartLabels,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildIncomeExpense(
                                    icon: 'lib/pages/assets/Income.png',
                                    title: 'Income',
                                    amount: '\$4,120.00',
                                    color: const Color(0xFF0D4015),
                                    screenWidth: screenWidth,
                                  ),
                                  _buildIncomeExpense(
                                    icon: 'lib/pages/assets/Expense.png',
                                    title: 'Expense',
                                    amount: '\$1,187.40',
                                    color: const Color(0xFF843F3F),
                                    screenWidth: screenWidth,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Text(
                              'My Targets',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF202422),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: _targets.map((target) => _buildTargetItem(
                                name: target['name'],
                                progress: target['progress'],
                                screenWidth: screenWidth,
                              )).toList(),
                            ),
                            SizedBox(height: screenHeight * 0.1),
                          ],
                        ),
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
