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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
               Icon(
  CupertinoIcons.arrow_up_left_square,
  size: 14,
  color: const Color.fromARGB(255, 255, 255, 255),
),
                const SizedBox(width: 8),
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFFFCFCFC),
                  ),
                ),
              ],
            ),
            Text(
              '\$$totalBalance',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFCFCFC),
              ),
            ),
          ],
        ),
        Container(width: 1, height: 42, color: const Color(0xFFFCFCFC)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
Icon(
  CupertinoIcons.arrow_down_right_square,
  size: 14,
  color: const Color.fromARGB(255, 255, 255, 255),
),
                const SizedBox(width: 8),
                const Text(
                  'Total Expense',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFFFCFCFC),
                  ),
                ),
              ],
            ),
            Text(
              '-\$$totalExpense',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFCFCFC),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
