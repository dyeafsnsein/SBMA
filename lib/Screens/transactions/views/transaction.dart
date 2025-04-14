import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/transaction_controller.dart';
import '../../../shared_components/income_expense_summary.dart';
import '../../../shared_components/add_transaction_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  void _showAddTransactionDialog(BuildContext context) {
    final controller = Provider.of<TransactionController>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        onAddExpense: (expense) {
          controller.addExpense(expense);
          Navigator.pop(context);
        },
        onAddIncome: (income) {
          controller.addIncome(income);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final controller = Provider.of<TransactionController>(context, listen: false);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.setFilterDate(pickedDate);
    }
  }

  Future<void> _deleteTransaction(BuildContext context, Map<String, dynamic> transaction) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Find the transaction in Firestore by matching fields
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('timestamp', isEqualTo: Timestamp.fromDate(transaction['timestamp']))
          .where('amount', isEqualTo: transaction['amount'])
          .where('category', isEqualTo: transaction['category'])
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        final amount = transaction['amount'] as double;

        // Use a batch to delete the transaction and update the balance
        final batch = FirebaseFirestore.instance.batch();
        final transactionRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(docId);
        batch.delete(transactionRef);

        // Update the user's balance
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDoc = await userRef.get();
        final currentBalance = (userDoc.data()?['balance'] as num?)?.toDouble() ?? 0.0;
        final newBalance = currentBalance - amount; // Subtract the amount (negative for expenses, positive for income)
        batch.update(userRef, {'balance': newBalance});

        await batch.commit();

        // Show a snackbar for user feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${transaction['category']} transaction deleted'),
          ),
        );
      }
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting transaction'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TransactionController>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF202422),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: const Color(0xFF202422),
                  padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.06,
                    screenHeight * 0.08,
                    screenWidth * 0.06,
                    screenHeight * 0.04,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/'),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: screenWidth * 0.06,
                            ),
                          ),
                          Text(
                            'Transactions',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/notification'),
                            child: Container(
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.08,
                              decoration: BoxDecoration(
                                color: const Color(0xFF050505),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.04,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: screenWidth * 0.05,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '\$${controller.totalBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      IncomeExpenseSummary(
                        income: controller.totalIncome,
                        expense: controller.totalExpenses,
                        onAddIncome: () => _showAddTransactionDialog(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 60,
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05,
                            bottom: screenWidth * 0.05,
                          ),
                          child: controller.transactions.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No transactions yet. Start adding some!',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: controller.transactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction = controller.transactions[index];
                                    final isExpense = transaction['type'] == 'expense';
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ListTile(
                                        leading: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              transaction['icon'] ?? 'lib/assets/Transaction.png',
                                              width: 28,
                                              height: 28,
                                              errorBuilder: (context, error, stackTrace) => Icon(
                                                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                                                color: isExpense ? Colors.red : Colors.green,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                        title: Text(
                                          transaction['category'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              transaction['timestamp'] != null
                                                  ? (transaction['timestamp'] as DateTime)
                                                      .toString()
                                                      .substring(0, 16)
                                                  : 'Unknown date',
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            if (transaction['description'] != null &&
                                                transaction['description'].isNotEmpty)
                                              Text(
                                                transaction['description'],
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '\$${(transaction['amount'] as double).abs().toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isExpense ? Colors.red : Colors.green,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () => _deleteTransaction(context, transaction),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => _showDatePicker(context),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF202422),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.calendar,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _showAddTransactionDialog(context),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF202422),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}