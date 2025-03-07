import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/analysis_header.dart';  // Use existing header component
import 'components/progress_bar.dart';
import 'components/fl_bar_chart.dart';
import 'components/bottom_nav_bar.dart';
import 'components/period_selector_analysis.dart';
import 'components/income_expense_summary.dart';  // Should use this component
import 'components/targets_section.dart';  // Should use this component
import 'Notification.dart';

class Analysis extends StatefulWidget {
  const Analysis({Key? key}) : super(key: key);

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> with SingleTickerProviderStateMixin {
  final List<String> _iconPaths = const [
    'lib/assets/Home.png',
    'lib/assets/Analysis.png',
    'lib/assets/Transactions.png',
    'lib/assets/Categories.png',
    'lib/assets/Profile.png',
  ];

  final List<String> _periods = const ['Daily', 'Weekly', 'Monthly', 'Year'];
  int _selectedPeriodIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Map to store period-specific data
  final Map<String, Map<String, dynamic>> _periodData = {
    'Daily': {
      'expenses': [5.0, 3.0, 4.0, 2.0, 6.0, 3.0, 4.0],
      'income': [3.0, 5.0, 2.0, 6.0, 2.0, 1.0, 3.0],
      'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    },
    'Weekly': {
      'expenses': [8.0, 3.0, 12.0, 9.0],
      'income': [10.0, 8.0, 12.0, 9.0],
      'labels': ['1st Week', '2nd Week', '3rd Week', '4th Week'],
    },
    'Monthly': {
      'expenses': [35.0, 38.0, 32.0, 40.0, 42.0, 36.0, 45.0, 39.0, 41.0, 37.0, 43.0, 44.0],
      'income': [80.0, 85.0, 75.0, 90.0, 82.0, 78.0, 88.0, 79.0, 86.0, 77.0, 89.0, 83.0],
      'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    },
    'Year': {
      'expenses': [400.0, 420.0, 450.0, 480.0],
      'income': [900.0, 950.0, 1000.0, 1100.0],
      'labels': ['2020', '2021', '2022', '2023'],
    },
  };

  final List<Map<String, dynamic>> _targets = [
    {
      'name': 'Travel',
      'progress': 0.3,
      'color': Color(0xFF00FF94),
    },
    {
      'name': 'Car',
      'progress': 0.5,
      'color': Color(0xFF00A3FF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPeriodChanged(int index) {
    if (_selectedPeriodIndex == index) return;
    
    setState(() {
      _selectedPeriodIndex = index;
    });
    
    // Animate chart transition
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Get current period data based on selection
    String currentPeriod = _periods[_selectedPeriodIndex];
    List<double> expenses = List<double>.from(_periodData[currentPeriod]!['expenses']);
    List<double> income = List<double>.from(_periodData[currentPeriod]!['income']);
    List<String> labels = List<String>.from(_periodData[currentPeriod]!['labels']);

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
                // Use the existing AnalysisHeader component
                const AnalysisHeader(
                  totalBalance: 7783.00,
                  totalExpense: 1187.40,
                  expensePercentage: 30,
                  expenseLimit: 20000.00,
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
                              periods: _periods,
                              selectedIndex: _selectedPeriodIndex,
                              onPeriodChanged: _onPeriodChanged,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: FlBarChart(
                                expenses: expenses,
                                income: income,
                                labels: labels,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            // Use the existing IncomeExpenseSummary component
                            const IncomeExpenseSummary(
                              income: 4120.00,
                              expense: 1187.40,
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            // Use the existing TargetsSection component
                            TargetsSection(targets: _targets),
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
