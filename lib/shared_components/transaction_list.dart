import 'package:flutter/material.dart';
import '../../Models/transaction_model.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionList({Key? key, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No transactions yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 0,
          bottom: 80,
        ),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final isExpense = transaction.type.toLowerCase() == 'expense';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7.0),
            child: Row(
              children: [
                Container(
                  width: 57,
                  height: 53,
                  decoration: BoxDecoration(
                    color: const Color(0xFF202422),
                    borderRadius: BorderRadius.circular(28.5),
                  ),
                  child: Center(
                    child: Image.asset(
                      transaction.icon,
                      width: 31,
                      height: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${transaction.date.hour.toString().padLeft(2, '0')}:${transaction.date.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF202422),
                      ),
                    ),
                    Text(
                      transaction.category,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF202422),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '\$${transaction.amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}