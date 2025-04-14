import 'package:flutter/material.dart';
import '../../../../shared_components/balance_overview.dart';

class AnalysisHeader extends StatelessWidget {
  final double totalBalance;
  final double totalExpense;
  final int expensePercentage; // Keep as int to match AnalysisPage
  final VoidCallback onBackPressed;
  final VoidCallback onNotificationTap;

  const AnalysisHeader({
    Key? key,
    required this.totalBalance,
    required this.totalExpense,
    required this.expensePercentage,
    required this.onBackPressed,
    required this.onNotificationTap,
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
                onTap: onBackPressed,
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
                onTap: onNotificationTap,
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
          BalanceOverview(
            totalBalance: totalBalance,
            totalExpense: totalExpense,
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_box,
                color: Colors.white,
                size: screenWidth * 0.04,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                '$expensePercentage% Of Your Expenses, Looks Good.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.035,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}