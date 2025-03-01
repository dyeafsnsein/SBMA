import 'package:flutter/material.dart';

class IncomeExpenseSummary extends StatelessWidget {
  final double income;
  final double expense;

  const IncomeExpenseSummary({
    Key? key,
    required this.income,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIncomeExpense(
            icon: 'lib/pages/assets/Income.png',
            title: 'Income',
            amount: '\$${income.toStringAsFixed(2)}',
            color: const Color(0xFF0D4015),
            screenWidth: screenWidth,
          ),
          _buildIncomeExpense(
            icon: 'lib/pages/assets/Expense.png',
            title: 'Expense',
            amount: '\$${expense.toStringAsFixed(2)}',
            color: const Color(0xFF843F3F),
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpense({
    required String icon,
    required String title,
    required String amount,
    required Color color,
    required double screenWidth,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          icon,
          width: screenWidth * 0.06,
          height: screenWidth * 0.06,
          color: color,
        ),
        SizedBox(height: screenWidth * 0.01),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
