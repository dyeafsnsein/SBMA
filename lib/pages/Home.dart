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
      'time': '8:30 - April 15',
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
                      padding: const EdgeInsets.fromLTRB(25, 60, 25, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Header(onNotificationTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NotificationPage()),
                            );
                          }),
                          const SizedBox(height: 20),
                          BalanceOverview(totalBalance: 7783.00, totalExpense: 1187.40),
                          const SizedBox(height: 20),
                          ProgressBar(progress: 0.3, goalAmount: 20000.00),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'lib/pages/assets/Check.png',
                                width: 11,
                                height: 11,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '30% of your expenses, looks good.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  color: Color(0xFFFCFCFC),
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
                          GoalOverview(
                            goalIcon: 'lib/pages/assets/Car.png',
                            goalText: 'Savings On Goals',
                            revenueLastWeek: 4000.00,
                            foodLastWeek: 100.00,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => QuickAnalysis()),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          PeriodSelector(
                            periods: _periods,
                            selectedPeriodIndex: _selectedPeriodIndex,
                            onPeriodTapped: _onPeriodTapped,
                          ),
                          const SizedBox(height: 20),
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
