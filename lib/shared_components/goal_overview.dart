import 'package:flutter/material.dart';

class GoalOverview extends StatelessWidget {
  final String goalIcon;
  final String goalText;
  final double revenueLastWeek;
  final String topCategoryLastWeek; // New: Dynamic category
  final double topCategoryAmountLastWeek; // New: Dynamic category amount
  final String topCategoryIconLastWeek; // New: Dynamic category icon
  final double goalAmount;
  final double currentBalance;
  final VoidCallback onTap;

  const GoalOverview({
    Key? key,
    required this.goalIcon,
    required this.goalText,
    required this.revenueLastWeek,
    required this.topCategoryLastWeek,
    required this.topCategoryAmountLastWeek,
    required this.topCategoryIconLastWeek,
    required this.goalAmount,
    required this.currentBalance,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = goalAmount > 0 ? (currentBalance / goalAmount).clamp(0.0, 1.0) : 0.0;
    final progressPercentage = (progress * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF202422), Color(0xFF2C3639)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 71,
                      height: 71,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3.25,
                        backgroundColor: const Color(0xFF6DB6FE).withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6DB6FE)),
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
                const SizedBox(height: 4),
                Text(
                  '$progressPercentage% Achieved',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFFCFCFC),
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 120,
              color: const Color(0xFFFCFCFC).withOpacity(0.3),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'lib/assets/Salary.png',
                          width: 31,
                          height: 28,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
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
                                '\$${revenueLastWeek.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFCFCFC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Image.asset(
                          topCategoryIconLastWeek,
                          width: 31,
                          height: 28,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.category,
                            color: Color(0xFFFCFCFC),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topCategoryLastWeek == 'None'
                                    ? 'No Expenses'
                                    : '$topCategoryLastWeek Last Week',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Color(0xFFFCFCFC),
                                ),
                              ),
                              Text(
                                topCategoryLastWeek == 'None'
                                    ? '\$0.00'
                                    : '-\$${topCategoryAmountLastWeek.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFCFCFC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}