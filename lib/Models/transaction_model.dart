class TransactionModel {
  double totalBalance;
  double totalIncome;
  double totalExpense;
  List<Map<String, dynamic>> transactions;

  TransactionModel({
    this.totalBalance = 0.0,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.transactions = const [],
  });
}