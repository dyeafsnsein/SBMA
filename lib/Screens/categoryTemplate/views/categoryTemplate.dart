import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart'; // Import auto_route
import '../../../../shared_components/progress_bar.dart';
import '../../../../shared_components/transaction_list.dart'; // Import your TransactionList
import '../../../Route/app_router.dart';

@RoutePage() // Add this annotation to make it work with auto_route
class CategoryTemplatePage extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;

  const CategoryTemplatePage({
    Key? key,
    @PathParam('categoryName') required this.categoryName, // Use @PathParam or @QueryParam if needed
    @PathParam('categoryIcon') required this.categoryIcon,
  }) : super(key: key);

  @override
  State<CategoryTemplatePage> createState() => _CategoryTemplatePageState();
}

class _CategoryTemplatePageState extends State<CategoryTemplatePage> {
  List<Map<String, String>> _transactions = [];
  List<Map<String, String>> _allTransactions = []; // To store the full list
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() {
    setState(() {
      _allTransactions = [
        {
          'icon': 'lib/assets/food_icon.png',
          'time': '18:27',
          'category': 'Dinner',
          'amount': '-26.00',
          'date': '2025-04-30',
        },
        {
          'icon': 'lib/assets/food_icon.png',
          'time': '15:00',
          'category': 'Delivery Pizza',
          'amount': '-18.35',
          'date': '2025-04-24',
        },
        {
          'icon': 'lib/assets/food_icon.png',
          'time': '12:30',
          'category': 'Lunch',
          'amount': '-15.40',
          'date': '2025-04-15',
        },
        {
          'icon': 'lib/assets/food_icon.png',
          'time': '9:30',
          'category': 'Brunch',
          'amount': '-12.13',
          'date': '2025-04-08',
        },
        {
          'icon': 'lib/assets/food_icon.png',
          'time': '20:50',
          'category': 'Dinner',
          'amount': '-27.20',
          'date': '2025-03-31',
        },
      ];
      _transactions = List.from(
        _allTransactions,
      ); // Initialize with all transactions
    });
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
      DateTime end = _selectedDateRange!.end.add(
        const Duration(days: 1),
      ); // Include end date

      setState(() {
        _transactions =
            _allTransactions.where((transaction) {
              DateTime transactionDate = DateTime.parse(transaction['date']!);
              return transactionDate.isAfter(start) &&
                  transactionDate.isBefore(end);
            }).toList();
      });
    } else {
      setState(() {
        _transactions = List.from(
          _allTransactions,
        ); // Reset to full list if no range selected
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double paddingTop = MediaQuery.of(context).padding.top;
    final double height = screenSize.height;
    final double width = screenSize.width;

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
                  height: height * 0.32,
                  child: Container(
                    color: const Color(0xFF202422),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        width * 0.06,
                        paddingTop + height * 0.02,
                        width * 0.06,
                        height * 0.02,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap:
                                    () =>
                                        context.router
                                            .pop(), // Use auto_route for back navigation
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: width * 0.06,
                                ),
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    widget.categoryIcon,
                                    width: 24,
                                    height: 24,
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Text(
                                    widget.categoryName,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: width * 0.06,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navigate to NotificationPage using auto_route
                                  context.router.push(
                                    const NotificationRoute(),
                                  );
                                },
                                child: Container(
                                  width: width * 0.08,
                                  height: width * 0.08,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF050505),
                                    borderRadius: BorderRadius.circular(
                                      width * 0.04,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                      size: width * 0.05,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBalanceInfo(
                                title: 'Total Balance',
                                amount: '\$7,783.00',
                              ),
                              _buildBalanceInfo(
                                title: 'Total Expense',
                                amount: '\$-1,187.40',
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProgressBar(
                                  progress: 0.3,
                                  goalAmount: 20000.00,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_box,
                                      color: Colors.white,
                                      size: width * 0.04,
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Text(
                                      '30% Of Your Expenses, Looks Good.',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: width * 0.035,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9EAD3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
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
                                      'lib/assets/Calendar.png',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _transactions.isEmpty
                              ? const Center(
                                child: Text('No transactions available'),
                              )
                              : TransactionList(transactions: _transactions),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                // Add navigation or logic for adding expenses here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF202422),
                                foregroundColor: Colors.white,
                                minimumSize: Size(width - 40, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Add Expenses',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
           
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfo({required String title, required String amount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}