import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
            icon: CupertinoIcons.arrow_up_right_square,
            title: 'Income',
            amount: '\$${income.toStringAsFixed(2)}',
            color: const Color(0xFF0D4015),
            screenWidth: screenWidth,
          ),
          
          _buildIncomeExpense(
            icon: CupertinoIcons.arrow_down_left_square,
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
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
    required double screenWidth,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: screenWidth * 0.08,
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
