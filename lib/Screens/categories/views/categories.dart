import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../shared_components/progress_bar.dart';
import '../../../shared_components/balance_overview.dart';
import 'components/newcategory.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryState();
}

class _CategoryState extends State<CategoryPage> {
  final List<Map<String, String>> _categories = [
    {'label': 'Shopping', 'icon': 'lib/assets/Shopping.png'},
    {'label': 'Food', 'icon': 'lib/assets/Food.png'},
    {'label': 'Transport', 'icon': 'lib/assets/Transport.png'},
    {'label': 'Entertainment', 'icon': 'lib/assets/Entertainment.png'},
    {'label': 'Health', 'icon': 'lib/assets/Health.png'},
    {'label': 'Education', 'icon': 'lib/assets/Education.png'},
    {'label': 'Bills', 'icon': 'lib/assets/Bills.png'},
    {'label': 'More', 'icon': 'lib/assets/More.png'},
  ];

  void _showNewCategoryDialog(BuildContext context) async {
  final result = await showDialog<Map<String, String>>(
    context: context,
    builder: (BuildContext context) => const NewCategoryDialog(),
  );
  
  if (result != null) {
    // Handle the new category
    setState(() {
      _categories.insert(_categories.length - 1, {
        'label': result['name']!,
        'icon': result['icon']!,
      });
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingTop = MediaQuery.of(context).padding.top;

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
                    paddingTop + screenHeight * 0.02,
                    screenWidth * 0.06,
                    screenHeight * 0.02,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/'),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: screenWidth * 0.06,
                            ),
                          ),
                          Text(
                            'Categories',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/notification'),
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
                      ProgressBar(progress: 0.3, goalAmount: 20000.00),
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
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: _categories.isEmpty
                          ? const Center(
                              child: Text('No categories available'),
                            )
                          : GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(
                                top: screenHeight * 0.02,
                                bottom: screenHeight * 0.08,
                              ),
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
                                        '/category-template/${category['label']}/${Uri.encodeComponent(category['icon']!)}',
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          category['icon']!,
                                          width: screenWidth * 0.12,
                                          height: screenWidth * 0.12,
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Text(
                                          category['label']!,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF202422),
                                          ),
                                        ),
                                      ],
                                    ),
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
}