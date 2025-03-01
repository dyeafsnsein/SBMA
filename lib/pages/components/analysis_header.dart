import 'package:flutter/material.dart';
import '../Notification.dart';

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationPage()),
                  );
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
          _buildBalanceOverview(),
          SizedBox(height: screenHeight * 0.02),
          _buildProgressBar(),
          SizedBox(height: screenHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/pages/assets/Check.png',
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

  Widget _buildBalanceOverview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              '\$${totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Total Expenses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              '\$${totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFFF5C5C),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Expense Limit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              '\$${expenseLimit.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: expensePercentage / 100,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF94)),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
