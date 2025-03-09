import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/bottom_nav_bar.dart';
import 'components/progress_bar.dart';
import 'components/header.dart';
import 'Notification.dart';
import 'newcategory.dart';

class Category extends StatefulWidget {
  const Category({Key? key}) : super(key: key);

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final List<String> _iconPaths = [
    'lib/assets/Home.png',
    'lib/assets/Analysis.png',
    'lib/assets/Transactions.png',
    'lib/assets/Categories.png',
    'lib/assets/Profile.png',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'icon': 'lib/assets/Food.png', 'label': 'Food'},
    {'icon': 'lib/assets/Car.png', 'label': 'Transport'},
    {'icon': 'lib/assets/Medicine.png', 'label': 'Medicine'},
    {'icon': 'lib/assets/Groceries.png', 'label': 'Groceries'},
    {'icon': 'lib/assets/Rent.png', 'label': 'Rent'},
    {'icon': 'lib/assets/Gift.png', 'label': 'Gifts'},
    {'icon': 'lib/assets/Saving.png', 'label': 'Savings'},
    {'icon': 'lib/assets/Entertainment.png', 'label': 'Entertainment'},
    {'icon': 'lib/assets/More.png', 'label': 'More'},
  ];

  void _showNewCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => NewCategory(
            onSave: (String categoryName) {
              setState(() {
                _categories.insert(_categories.length - 1, {
                  'icon': 'lib/assets/Star.png',
                  'label': categoryName,
                });
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double paddingTop = MediaQuery.of(context).padding.top;
    final double height = screenSize.height;
    final double width = screenSize.width;

    final double topSectionHeight = height * 0.32;
    final double horizontalPadding = width * 0.06;
    final double verticalPadding = height * 0.02;

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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: width * 0.06,
                                ),
                              ),
                              Text(
                                'Categories',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: width * 0.06,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const NotificationPage(),
                                    ),
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
                                    child: Image.asset(
                                      'lib/assets/Notification.png',
                                      width: width * 0.05,
                                      height: width * 0.05,
                                      color: Colors.white,
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
                                amount: '-\$1,187.40',
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ProgressBar(
                                  progress: 0.3,
                                  goalAmount: 20000.00,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Image.asset(
                                      'lib/assets/Check.png',
                                      width: width * 0.04,
                                      height: width * 0.04,
                                      color: Colors.white,
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
                      color: Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return GestureDetector(
                            onTap:
                                category['label'] == 'More'
                                    ? () => _showNewCategoryDialog(context)
                                    : null,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF202422),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      category['icon'],
                                      width: 45,
                                      height: 45,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category['label'],
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF202422),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavBar(iconPaths: _iconPaths, selectedIndex: 3),
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
