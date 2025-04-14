import 'package:flutter/material.dart';

class TransactionAddExpensePage extends StatelessWidget {
  final Function(Map<String, String>) onSave; // Add onSave parameter

  const TransactionAddExpensePage({Key? key, required this.onSave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCategory = 'Food'; // Default category

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: const Color(0xFF202422),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (value) {
                selectedCategory = value!;
              },
              items: [
                'Food',
                'Transport',
                'Rent',
                'Entertainment',
                'Medicine',
                'Groceries',
                'More'
              ].map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final expenseData = {
                  'amount': amountController.text,
                  'description': descriptionController.text,
                  'category': selectedCategory,
                  'type': 'expense',
                };
                onSave(expenseData); // Call onSave with the expense data
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}