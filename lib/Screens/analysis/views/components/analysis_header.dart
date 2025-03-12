import 'package:flutter/material.dart';
import '../../../../shared_components/balance_overview.dart';
import '../../../../shared_components/progress_bar.dart';
import 'package:test_app/route/app_router.dart'; // Adjust the import path as necessary
import 'package:auto_route/auto_route.dart';
class AnalysisHeader extends StatelessWidget {
  final double totalBalance;
  final double totalExpense;
  final int expensePercentage;
  final double expenseLimit;

  const AnalysisHeader({
    Key? key,
    required this.totalBalance,
    required this.totalExpense,
    required this.expensePercentage,
    required this.expenseLimit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
            context.router.push(const NotificationRoute());
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
          // Using the imported BalanceOverview widget
          BalanceOverview(
            totalBalance: totalBalance,
            totalExpense: totalExpense,
          ),
          SizedBox(height: screenHeight * 0.02),
          // Using the imported ProgressBar widget
          ProgressBar(
            progress: expensePercentage / 100,
            goalAmount: expenseLimit,
          ),
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
                '$expensePercentage% Of Your Expenses, Looks Good.',
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
}
