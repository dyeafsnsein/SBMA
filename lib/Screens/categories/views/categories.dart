import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'components/newcategory.dart'; // Import NewCategoryDialog
import '../../saving/saving.dart'; // Import SavingsPage
import '../../../Controllers/home_controller.dart'; // Import HomeController

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryState();
}

class _CategoryState extends State<CategoryPage> {
  final List<Map<String, String>> _categories = [
    {'label': 'Food', 'icon': 'lib/assets/Food.png'},
    {'label': 'Transport', 'icon': 'lib/assets/Transport.png'},
    {'label': 'Rent', 'icon': 'lib/assets/Rent.png'},
    {'label': 'Entertainment', 'icon': 'lib/assets/Entertainment.png'},
    {'label': 'Medicine', 'icon': 'lib/assets/Medicine.png'},
    {'label': 'Groceries', 'icon': 'lib/assets/Groceries.png'},
    {'label': 'More', 'icon': 'lib/assets/More.png'},
  ];

  void _showNewCategoryDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) => const NewCategoryDialog(),
    );

    if (result != null) {
      setState(() {
        _categories.add({'label': result['name'], 'icon': result['icon']});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context); // Access HomeController
    final Size screenSize = MediaQuery.of(context).size;
    final double paddingTop = MediaQuery.of(context).padding.top;
    final double height = screenSize.height;
    final double width = screenSize.width;

    final double topSectionHeight = height * 0.32;
    final double horizontalPadding = width * 0.06;
    final double verticalPadding = height * 0.02;

    // Calculate the percentage of expenses dynamically
    final double expensePercentage = controller.totalBalance > 0
        ? (controller.totalExpense / controller.totalBalance * 100).toDouble()
        : 0.0;

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
                                onTap: () => context.pop(),
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
                                  context.push('/notification');
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
                                amount: '\$${controller.totalBalance.toStringAsFixed(2)}', // Use HomeController
                              ),
                              _buildBalanceInfo(
                                title: 'Total Expense',
                                amount: '-\$${controller.totalExpense.toStringAsFixed(2)}', // Use HomeController
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                            
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
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 20, bottom: 80),
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
                            onTap: () {
                              if (category['label'] == 'More') {
                                _showNewCategoryDialog(context);
                              } else {
                                context.push(
                                  '/categories/template/${category['label']}/${Uri.encodeComponent(category['icon']!)}',
                                );
                              }
                            },
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
                                      category['icon'] ?? '',
                                      width: 45,
                                      height: 45,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category['label'] ?? '',
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
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
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