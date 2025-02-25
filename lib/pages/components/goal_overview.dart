import 'package:flutter/material.dart';

class GoalOverview extends StatelessWidget {
  final String goalIcon;
  final String goalText;
  final double revenueLastWeek;
  final double foodLastWeek;
  final VoidCallback onTap; // Add this

  const GoalOverview({
    Key? key,
    required this.goalIcon,
    required this.goalText,
    required this.revenueLastWeek,
    required this.foodLastWeek,
    required this.onTap, // Add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Wrap with GestureDetector
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: const Color(0xFF202422),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 71,
                      height: 71,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF6DB6FE),
                          width: 3.25,
                        ),
                      ),
                    ),
                    Image.asset(
                      goalIcon,
                      width: 37.57,
                      height: 21.75,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  goalText,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFCFCFC),
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 108,
              color: const Color(0xFFFCFCFC),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'lib/pages/assets/Salary.png',
                      width: 31,
                      height: 28,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Revenue Last Week',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFFFCFCFC),
                          ),
                        ),
                        Text(
                          '\$$revenueLastWeek',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFCFCFC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Image.asset(
                      'lib/pages/assets/Food.png',
                      width: 31,
                      height: 28,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Food Last Week',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFFFCFCFC),
                          ),
                        ),
                        Text(
                          '-\$$foodLastWeek',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFCFCFC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
