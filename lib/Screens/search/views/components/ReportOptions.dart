import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Controllers/search_controller.dart' as custom;

class ReportOptions extends StatelessWidget {
  const ReportOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<custom.SearchController>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF202422),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          children: [
            _buildRadioOption(
              title: 'Income',
              isSelected: controller.isIncome,
              onTap: () {
                controller.toggleIncome(true);
              },
            ),
            SizedBox(width: screenWidth * 0.06),
            _buildRadioOption(
              title: 'Expense',
              isSelected: controller.isExpense,
              onTap: () {
                controller.toggleExpense(true);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF202422),
                width: 2,
              ),
            ),
            child: isSelected
                ? Container(
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF202422),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Color(0xFF202422),
            ),
          ),
        ],
      ),
    );
  }
}