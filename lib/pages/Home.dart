import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/header.dart';
import 'components/balance_overview.dart';
import 'components/progress_bar.dart';
import 'components/goal_overview.dart';
import 'components/period_selector.dart';
import 'components/transaction_list.dart';
import 'components/bottom_nav_bar.dart';
import 'Notification.dart'; // Ensure this is the correct import
import 'QuickAnalysis.dart'; // Ensure this is the correct import

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  int _selectedPeriodIndex = 2; // Default to "Monthly"

  final List<String> _iconPaths = [
    'lib/pages/assets/Home.png',
    'lib/pages/assets/Analysis.png',
    'lib/pages/assets/Transactions.png',
    'lib/pages/assets/Categories.png',
    'lib/pages/assets/Profile.png',
  ];

  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  final List<Map<String, String>> _transactions = [
    {
      'icon': 'lib/pages/assets/Salary.png',
      'time': '18:27 - April 30',
      'category': 'Monthly',
      'amount': '\$4,000.00',
    },
    {
      'icon': 'lib/pages/assets/Pantry.png',
      'time': '17:00 - April 24',
      'category': 'Pantry',
      'amount': '-\$100.00',
    },
    {
      'icon': 'lib/pages/assets/Rent.png',
      'time': '8:30 - April 1155',
      'category': 'Rent',
      'amount': '-\$874.40',
    },
    {
      'icon': 'lib/pages/assets/Rent.png',
      'time': '9:30 - April 25',
      'category': 'Rent',
      'amount': '-\$774.40',
    },
    {
      'icon': 'lib/pages/assets/Rent.png',
      'time': '9:30 - April 25',
      'category': 'Rent',
      'amount': '-\$774.40',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onPeriodTapped(int index) {
    setState(() {
      _selectedPeriodIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF202422),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Column(
                  children: [
                    // Top Section (36% of screen height)
                    Expanded(
                      flex: 36,
                      child: Container(
                        color: const Color(0xFF202422),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                screenWidth * 0.06, // 6% of screen width
                            vertical:
                                screenHeight * 0.06, // 6% of screen height
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Header(
                                onNotificationTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NotificationPage(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              ), // 2% of screen height
                              BalanceOverview(
                                totalBalance: 7783.00,
                                totalExpense: 1187.40,
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              ), // 2% of screen height
                              ProgressBar(progress: 0.3, goalAmount: 20000.00),
                              SizedBox(
                                height: screenHeight * 0.01,
                              ), // 1% of screen height
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'lib/pages/assets/Check.png',
                                    width:
                                        screenWidth *
                                        0.03, // 3% of screen width
                                    height:
                                        screenWidth *
                                        0.03, // 3% of screen width
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.02,
                                  ), // 2% of screen width
                                  Text(
                                    '30% of your expenses, looks good.',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize:
                                          screenWidth *
                                          0.037, // 4% of screen width
                                      color: const Color(0xFFFCFCFC),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottom Section (64% of screen height)
                    Expanded(
                      flex: 64,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1FFF3),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                            screenWidth * 0.05,
                          ), // 5% of screen width
                          child: Column(
                            children: [
                              GoalOverview(
                                goalIcon: 'lib/pages/assets/Car.png',
                                goalText: 'Savings On Goals',
                                revenueLastWeek: 4000.00,
                                foodLastWeek: 100.00,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuickAnalysis(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              ), // 2% of screen height
                              PeriodSelector(
                                periods: _periods,
                                selectedPeriodIndex: _selectedPeriodIndex,
                                onPeriodTapped: _onPeriodTapped,
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              ), // 2% of screen height
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
                // Bottom Navigation Bar
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomNavBar(
                    iconPaths: _iconPaths,
                    selectedIndex: _selectedIndex,
                    onItemTapped: _onItemTapped,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
