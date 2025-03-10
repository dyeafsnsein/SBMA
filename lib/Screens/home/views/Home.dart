import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/header.dart';
import '../../../shared_components/balance_overview.dart';
import '../../../shared_components/progress_bar.dart';
import 'components/goal_overview.dart';
import 'components/period_selector.dart';
import '../../../shared_components/transaction_list.dart';
import '../../../shared_components/bottom_nav_bar.dart';
import '../../notification/views/Notification.dart';
import '../../quick_analysis/views/QuickAnalysis.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedPeriodIndex = 2;

  final List<String> _iconPaths = [
    'lib/assets/Home.png',
    'lib/assets/Analysis.png',
    'lib/assets/Transactions.png',
    'lib/assets/Categories.png',
    'lib/assets/Profile.png',
  ];

  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  final List<Map<String, String>> _transactions = [
    {
      'icon': 'lib/assets/Salary.png',
      'time': '18:27 - April 30',
      'category': 'Monthly',
      'amount': '\$4,000.00',
    },
    {
      'icon': 'lib/assets/Pantry.png',
      'time': '17:00 - April 24',
      'category': 'Pantry',
      'amount': '-\$100.00',
    },
    {
      'icon': 'lib/assets/Rent.png',
      'time': '8:30 - April 15',
      'category': 'Rent',
      'amount': '-\$874.40',
    },
    {
      'icon': 'lib/assets/Rent.png',
      'time': '9:30 - April 25',
      'category': 'Rent',
      'amount': '-\$774.40',
    },
    {
      'icon': 'lib/assets/Rent.png',
      'time': '9:30 - April 25',
      'category': 'Rent',
      'amount': '-\$774.40',
    },
    {
      'icon': 'lib/assets/Pantry.png',
      'time': '17:00 - April 24',
      'category': 'Pantry',
      'amount': '-\$100.00',
    },
    {
      'icon': 'lib/assets/Pantry.png',
      'time': '18:00 - April 24',
      'category': 'Pantry',
      'amount': '-\$100.00',
    },
  ];

  void _onPeriodTapped(int index) {
    setState(() {
      _selectedPeriodIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height ;
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
                Expanded(
                  flex: 36,
                  child: Container(
                    color: const Color(0xFF202422),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.06,
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
                                'lib/assets/Check.png',
                                width: screenWidth * 0.03,
                                height: screenWidth * 0.03,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                '30% of your expenses, looks good.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: screenWidth * 0.037,
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
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        children: [
                          GoalOverview(
                            goalIcon: 'lib/assets/Car.png',
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
                          SizedBox(height: screenHeight * 0.02),
                          PeriodSelector(
                            periods: _periods,
                            selectedPeriodIndex: _selectedPeriodIndex,
                            onPeriodTapped: _onPeriodTapped,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Expanded(
                            child: TransactionList(transactions: _transactions),
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
                selectedIndex: 0, // Home page index
              ),
            ),
          ],
        ),
      ),
    );
  }
}
