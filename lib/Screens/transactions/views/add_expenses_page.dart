import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../Controllers/category_controller.dart';

class TransactionAddExpensePage extends StatefulWidget {
  final Function(Map<String, String>) onSave;

  const TransactionAddExpensePage({Key? key, required this.onSave}) : super(key: key);

  @override
  TransactionAddExpensePageState createState() => TransactionAddExpensePageState();
}

class TransactionAddExpensePageState extends State<TransactionAddExpensePage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final categoryController = Provider.of<CategoryController>(context);

    // Use expenseCategories and filter out "More"
    final categories = categoryController.expenseCategories
        .where((category) => category.label != 'More')
        .toList();

    // Set default category if not set
    if (selectedCategory == null && categories.isNotEmpty) {
      selectedCategory = categories.first.label;
    } else if (selectedCategory != null && !categories.any((category) => category.label == selectedCategory)) {
      selectedCategory = categories.isNotEmpty ? categories.first.label : null;
    }

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
            categories.isEmpty
                ? const Text('No categories available')
                : DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.label,
                        child: Text(category.label),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory != null) {
                  final expenseData = {
                    'amount': amountController.text,
                    'description': descriptionController.text,
                    'category': selectedCategory!,
                    'type': 'expense',
                  };
                  widget.onSave(expenseData);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}