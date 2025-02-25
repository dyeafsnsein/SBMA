import 'package:flutter/material.dart';

class PeriodSelector extends StatelessWidget {
  final List<String> periods;
  final int selectedPeriodIndex;
  final ValueChanged<int> onPeriodTapped;

  const PeriodSelector({
    Key? key,
    required this.periods,
    required this.selectedPeriodIndex,
    required this.onPeriodTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Adjust padding
      decoration: BoxDecoration(
        color: const Color(0xFF202422),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Use spaceEvenly
        children: List.generate(periods.length, (index) {
          final isSelected = selectedPeriodIndex == index;
          return GestureDetector(
            onTap: () => onPeriodTapped(index),
            child: Container(
              width: (MediaQuery.of(context).size.width - 80) / 3,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 215, 211, 211)
                    : const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(19),
              ),
              alignment: Alignment.center,
              child: Text(
                periods[index],
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF202422),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
