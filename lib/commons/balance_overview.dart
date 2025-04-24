import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class BalanceOverview extends StatelessWidget {
  final double totalBalance;
  final double totalExpense;

  const BalanceOverview({
    Key? key,
    required this.totalBalance,
    required this.totalExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.arrow_up_left_square,
                        size: screenWidth * 0.035,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.03,
                          color: const Color(0xFFFCFCFC),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$${totalBalance.toStringAsFixed(3)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFCFCFC),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: screenHeight * 0.05,
              color: const Color(0xFFFCFCFC),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.arrow_down_right_square,
                        size: screenWidth * 0.035,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Total Expense',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.03,
                          color: const Color(0xFFFCFCFC),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '-\$$totalExpense',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFCFCFC),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
