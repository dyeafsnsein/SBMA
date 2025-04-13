class TransactionModel {
  final String type;
  final double amount;
  final DateTime date;
  final String description;
  final String category;
  final String icon;

  TransactionModel({
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.category,
    required this.icon,
  });
}