import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddTransactionDialog extends StatelessWidget {
  final Function(Map<String, String>) onAddExpense;
  final Function(Map<String, String>) onAddIncome;

  const AddTransactionDialog({
    super.key,
    required this.onAddExpense,
    required this.onAddIncome,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF202422),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        'Add New',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.arrow_upward,
              color: Color(0xFF0D4015),
            ),
            title: const Text(
              'Income',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('/transactions/add-income', extra: onAddIncome);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.arrow_downward,
              color: Color(0xFF843F3F),
            ),
            title: const Text(
              'Expense',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('/transactions/add-expense', extra: onAddExpense);
            },
          ),
        ],
      ),
    );
  }
} 