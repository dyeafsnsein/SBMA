import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controllers/transaction_controller.dart';
import '../Models/transaction_model.dart';
import '../Services/data_service.dart';
import 'add_transaction_dialog.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isHomePage;

  const TransactionList({
    super.key,
    required this.transactions,
    this.isHomePage = false,
  });
  @override
  Widget build(BuildContext context) {    final transactionController = Provider.of<TransactionController>(context);
    final dataService = Provider.of<DataService>(context, listen: false);

    return ListView.builder(
      itemCount: transactions.length,      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isExpense = transaction.type == 'expense';

        return GestureDetector(
          onTap: () {
            if (!isHomePage) {
              showDialog(
                context: context,
                builder: (context) => AddTransactionDialog(
                  initialTransaction: transaction,
                  onAddExpense: (expense) {
                    transactionController.updateTransaction(expense);
                    Navigator.pop(context);
                  },
                  onAddIncome: (income) {
                    transactionController.updateTransaction(income);
                    Navigator.pop(context);
                  },
                ),
              );
            }
          },
          onLongPress: () {
            if (!isHomePage) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Transaction'),
                  content: const Text(
                      'Are you sure you want to delete this transaction?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        transactionController.deleteTransaction(transaction);
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
        ),
      );
    }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [                Container(
                  width: 57,
                  height: 53,
                  decoration: BoxDecoration(
                    color: const Color(0xFF202422),
                    borderRadius: BorderRadius.circular(28.5),
                  ),
                  child: Center(                    child: Image.asset(
                      transaction.icon.isNotEmpty 
                          ? transaction.icon 
                          : dataService.getIconForCategory(transaction.category),
                      width: 31,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) {
                        // Better error handling for icon loading
                        debugPrint(
                            'Failed to load icon: ${transaction.icon}, error: $error');
                        return Icon(
                          isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                          color: Colors.white,
                          size: 28,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? '-' : '+'}\$${transaction.amount.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
          );
        },
    );
  }
}
