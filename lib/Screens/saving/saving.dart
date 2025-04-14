import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../Controllers/home_controller.dart'; // Import HomeController
import 'saving_analysis.dart'; // Import the SavingsAnalysisPage

class SavingsPage extends StatelessWidget {
  const SavingsPage({Key? key}) : super(key: key);

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
                                'Savings',
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
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [],
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
                        itemCount: 4, // Number of savings categories
                        itemBuilder: (context, index) {
                          final List<Map<String, String>> savingsCategories = [
                            {
                              'label': 'Travel',
                              'icon': 'lib/assets/Travel.png',
                            },
                            {
                              'label': 'New House',
                              'icon': 'lib/assets/New House.png',
                            },
                            {'label': 'Car', 'icon': 'lib/assets/Car.png'},
                            {
                              'label': 'Wedding',
                              'icon': 'lib/assets/Wedding.png',
                            },
                          ];

                          final category = savingsCategories[index];
                          return GestureDetector(
                            onTap: () {
                              final categoryName =
                                  category['label'] ?? 'Unknown';
                              final iconPath =
                                  category['icon'] ?? 'lib/assets/default.png';

                              print(
                                'Navigating to SavingsAnalysisPage with: $categoryName, $iconPath',
                              ); // Debug print
                              context.push(
                                '/savings-analysis',
                                extra: {
                                  'categoryName': categoryName,
                                  'iconPath': iconPath,
                                },
                              );
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
                                      category['icon'] ??
                                          'lib/assets/default.png',
                                      width: 45,
                                      height: 45,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category['label'] ?? 'Unknown',
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
            Positioned(
              bottom: height * 0.12,
              left: width * 0.05,
              right: width * 0.05,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    print('Add More tapped');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF202422),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.015,
                      horizontal: width * 0.06,
                    ),
                    minimumSize: Size(width * 0.3, height * 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Add More',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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