import 'package:flutter/material.dart';

class TransactionAddIncomePage extends StatelessWidget {
  final Function(Map<String, String>) onSave; // Add onSave parameter

  const TransactionAddIncomePage({Key? key, required this.onSave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCategory = 'Income'; // Default category

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income'),
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
                'Income',
              ].map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final incomeData = {
                  'amount': amountController.text,
                  'description': descriptionController.text,
                  'category': selectedCategory,
                  'type': 'income',
                };
                onSave(incomeData); // Call onSave with the income data
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