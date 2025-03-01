import 'package:flutter/material.dart';

class PeriodSelector extends StatelessWidget {
  final List<String> periods;
  final int selectedIndex;
  final Function(int) onPeriodChanged;

  const PeriodSelector({
    Key? key,
    required this.periods,
    required this.selectedIndex,
    required this.onPeriodChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF202422),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(periods.length, (index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onPeriodChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                periods[index],
                style: TextStyle(
                  color: isSelected ? const Color(0xFF202422) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
