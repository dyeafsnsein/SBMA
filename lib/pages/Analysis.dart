import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/balance_overview.dart';
import 'components/progress_bar.dart';
import 'components/fl_bar_chart.dart';
import 'components/bottom_nav_bar.dart';
import 'components/period_selector_analysis.dart'; // Import the PeriodSelector
import 'Notification.dart';

class Analysis extends StatefulWidget {
  const Analysis({Key? key}) : super(key: key);

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> with SingleTickerProviderStateMixin {
  final List<String> _iconPaths = const [
    'lib/pages/assets/Home.png',
    'lib/pages/assets/Analysis.png',
    'lib/pages/assets/Transactions.png',
    'lib/pages/assets/Categories.png',
    'lib/pages/assets/Profile.png',
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
    final isTablet = screenWidth > 600;
    
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
                _buildHeader(context, screenWidth, screenHeight),
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
                        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Use the imported PeriodSelector widget with correct parameter names
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
                            _buildIncomeExpenseSummary(screenWidth),
                            SizedBox(height: screenHeight * 0.03),
                            _buildTargetsSection(screenWidth, screenHeight),
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

  Widget _buildHeader(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
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
                    MaterialPageRoute(builder: (context) => const NotificationPage()),
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
          const BalanceOverview(
            totalBalance: 7783.00,
            totalExpense: 1187.40,
          ),
          SizedBox(height: screenHeight * 0.02),
          const ProgressBar(progress: 0.3, goalAmount: 20000.00),
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
    );
  }

  Widget _buildIncomeExpenseSummary(double screenWidth) {
    return Padding(
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

  Widget _buildTargetsSection(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            color: target['color'],
            screenWidth: screenWidth,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTargetItem({
    required String name,
    required double progress,
    required Color color,
    required double screenWidth,
  }) {
    return Container(
      width: screenWidth * 0.4,
      height: screenWidth * 0.4,
      decoration: BoxDecoration(
        color: const Color(0xFF202422),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    child: CircularProgressIndicator(
                      value: value,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeWidth: 8,
                    ),
                  ),
                  Text(
                    '${(value * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
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
}
