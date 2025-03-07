import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'components/transaction_list.dart'; // Import the TransactionList component
import 'components/bottom_nav_bar.dart';
import 'Notification.dart';
import 'Home.dart';

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final List<String> _iconPaths = [
    'lib/pages/assets/Home.png',
    'lib/pages/assets/Analysis.png',
    'lib/pages/assets/Transactions.png',
    'lib/pages/assets/Categories.png',
    'lib/pages/assets/Profile.png',
  ];

  List<Map<String, String>> _transactions = [];
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchDataFromBackend();
  }

  void _fetchDataFromBackend() {
    setState(() {
      _transactions = [
        {
          'icon': 'lib/pages/assets/Salary.png',
          'time': '18:27 - April 30',
          'category': 'Monthly',
          'amount': '4000.00',
          'title': 'Salary',
          'date': '2023-04-30',
        },
        {
          'icon': 'lib/pages/assets/Pantry.png',
          'time': '17:00 - April 24',
          'category': 'Pantry',
          'amount': '-100.00',
          'title': 'Groceries',
          'date': '2023-04-24',
        },
        {
          'icon': 'lib/pages/assets/Rent.png',
          'time': '8:30 - April 15',
          'category': 'Rent',
          'amount': '-674.40',
          'title': 'Rent',
          'date': '2023-04-15',
        },
        {
          'icon': 'lib/pages/assets/Transport.png',
          'time': '7:30 - April 08',
          'category': 'Fuel',
          'amount': '-4.13',
          'title': 'Transport',
          'date': '2023-04-08',
        },
        {
          'icon': 'lib/pages/assets/Food.png',
          'time': '19:30 - March 31',
          'category': 'Dinner',
          'amount': '-70.40',
          'title': 'Food',
          'date': '2023-03-31',
        },
      ];

      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _totalIncome = _transactions
        .where((transaction) => double.parse(transaction['amount']!) > 0)
        .fold(
          0.0,
          (sum, transaction) => sum + double.parse(transaction['amount']!),
        );

    _totalExpense = _transactions
        .where((transaction) => double.parse(transaction['amount']!) < 0)
        .fold(
          0.0,
          (sum, transaction) => sum + double.parse(transaction['amount']!),
        );

    _totalBalance = _totalIncome + _totalExpense;
  }

  void _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF202422),
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF202422),
              secondary: const Color(0xFF0D4015),
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _filterTransactionsByDate();
      });
    }
  }

  void _filterTransactionsByDate() {
    if (_selectedDateRange != null) {
      DateTime start = _selectedDateRange!.start;
      DateTime end = _selectedDateRange!.end;

      _transactions =
          _transactions.where((transaction) {
            DateTime transactionDate = DateTime.parse(transaction['date']!);
            return transactionDate.isAfter(start) &&
                transactionDate.isBefore(end);
          }).toList();

      _calculateTotals();
    }
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
                  padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.06,
                    screenHeight * 0.08,
                    screenWidth * 0.06,
                    screenHeight * 0.04,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Home(),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: screenWidth * 0.06,
                            ),
                          ),
                          Text(
                            'Transactions',
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
                                MaterialPageRoute(
                                  builder: (context) => NotificationPage(),
                                ),
                              );
                            },
                            child: Container(
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.08,
                              decoration: BoxDecoration(
                                color: const Color(0xFF050505),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.04,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: screenWidth * 0.05,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '\$${_totalBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: _buildIncomeExpenseBox(
                              icon: CupertinoIcons.arrow_up_right_square,
                              title: 'Income',
                              amount: '\$${_totalIncome.toStringAsFixed(2)}',
                              color: const Color(0xFF0D4015),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: _buildIncomeExpenseBox(
                              icon: CupertinoIcons.arrow_down_left_square,
                              title: 'Expense',
                              amount:
                                  '\$${_totalExpense.abs().toStringAsFixed(2)}',
                              color: const Color(0xFF843F3F),
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
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 60,
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05,
                            bottom: screenWidth * 0.05,
                          ),
                          child: TransactionList(transactions: _transactions),
                        ),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: _pickDateRange,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'lib/pages/assets/Calendar.png',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavBar(iconPaths: _iconPaths, selectedIndex: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseBox({
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
      width: 171,
      height: 101,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}