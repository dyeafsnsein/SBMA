import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final DateTime date;
  final String description;
  final String category;
  final String categoryId;
  final String icon;

  static const String TYPE_INCOME = 'income';
  static const String TYPE_EXPENSE = 'expense';
  static const List<String> VALID_TYPES = [TYPE_INCOME, TYPE_EXPENSE];

  /// Creates a new transaction with the given parameters
  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.category,
    required this.categoryId,
    required this.icon,
  });

  /// Creates a copy of an existing transaction
  TransactionModel.copy(TransactionModel other)
      : id = other.id,
        type = other.type,
        amount = other.amount,
        date = other.date,
        description = other.description,
        category = other.category,
        categoryId = other.categoryId,
        icon = other.icon;

  /// Creates a new expense transaction with standardized values
  factory TransactionModel.expense({
    String id = '',
    required double amount,
    required DateTime date,
    required String description,
    required String category,
    required String categoryId,
    required String icon,
  }) {
    return TransactionModel(
      id: id,
      type: TYPE_EXPENSE,
      // Store expense amount as negative
      amount: -amount.abs(),
      date: date,
      description: description,
      category: category,
      categoryId: categoryId,
      icon: icon,
    );
  }

  /// Creates a new income transaction with standardized values
  factory TransactionModel.income({
    String id = '',
    required double amount,
    required DateTime date,
    required String description,
    String category = 'Income',
    String categoryId = 'income',
    String icon = 'lib/assets/Income.png',
  }) {
    return TransactionModel(
      id: id,
      type: TYPE_INCOME,
      // Store income amount as positive
      amount: amount.abs(),
      date: date,
      description: description,
      category: category,
      categoryId: categoryId,
      icon: icon,
    );
  }

  /// Creates a transaction model from Firestore document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Firestore document data is null for ID: ${doc.id}');
    }

    final timestamp = data['timestamp'] as Timestamp?;
    final type = data['type'] as String? ?? TYPE_EXPENSE;
    final amountRaw = data['amount'] as num?;
    final amount = amountRaw?.toDouble() ?? 0.0;
    final category = data['category'] as String? ?? 'Unknown';

    // Get icon directly from Firestore if available
    final icon = data['icon'] is String && (data['icon'] as String).isNotEmpty
        ? data['icon'] as String
        : ''; // Empty string will trigger getIconForCategory in UI if needed

    return TransactionModel(
      id: doc.id,
      type: VALID_TYPES.contains(type) ? type : TYPE_EXPENSE,
      amount: amount.isNaN || amount.isInfinite ? 0.0 : amount,
      date: timestamp != null ? timestamp.toDate().toLocal() : DateTime.now(),
      description: data['description'] as String? ?? '',
      category: category,
      categoryId: data['categoryId'] as String? ?? 'unknown',
      icon: icon,
    );
  }

  /// Creates a transaction model from a local Map (for shared_preferences)
  static TransactionModel fromLocal(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? TYPE_EXPENSE;
    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final dateRaw = data['timestamp'];
    DateTime date;
    if (dateRaw is String) {
      date = DateTime.tryParse(dateRaw) ?? DateTime.now();
    } else if (dateRaw is int) {
      date = DateTime.fromMillisecondsSinceEpoch(dateRaw);
    } else if (dateRaw is DateTime) {
      date = dateRaw;
    } else {
      date = DateTime.now();
    }
    return TransactionModel(
      id: data['id'] as String? ?? '',
      type: VALID_TYPES.contains(type) ? type : TYPE_EXPENSE,
      amount: amount.isNaN || amount.isInfinite ? 0.0 : amount,
      date: date,
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Unknown',
      categoryId: data['categoryId'] as String? ?? 'unknown',
      icon: data['icon'] as String? ?? '',
    );
  }

  /// Converts the transaction to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'amount': amount,
      'timestamp': Timestamp.fromDate(date),
      'description': description,
      'category': category,
      'categoryId': categoryId,
      'icon': icon,
    };
  }

  /// Creates a copy of this transaction with modified fields
  TransactionModel copyWith({
    String? id,
    String? type,
    double? amount,
    DateTime? date,
    String? description,
    String? category,
    String? categoryId,
    String? icon,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      icon: icon ?? this.icon,
    );
  }

  /// Returns the absolute amount value
  double get absoluteAmount => amount.abs();

  /// Returns true if this is an expense transaction
  bool get isExpense => type == TYPE_EXPENSE;

  /// Returns true if this is an income transaction
  bool get isIncome => type == TYPE_INCOME;

  /// Formats the transaction date using the specified format (defaults to MM/dd/yyyy)
  String formatDate([String format = 'MM/dd/yyyy']) {
    return DateFormat(format).format(date);
  }

  /// Returns a display-friendly string of the transaction amount
  String get displayAmount {
    final formatter = NumberFormat.currency(symbol: '\$');
    return formatter.format(absoluteAmount);
  }

  /// Returns a display-friendly string of the transaction amount with a custom currency symbol
  String formatAmount({String symbol = '\$', String locale = 'en_US'}) {
    final formatter = NumberFormat.currency(symbol: symbol, locale: locale);
    return formatter.format(absoluteAmount);
  }

  /// Returns a formatted string showing the transaction type with the amount
  String get displayTypeWithAmount {
    final prefix = isIncome ? '+' : '-';
    return '$prefix$displayAmount';
  }

  /// Returns a color-coded amount string (without actually including color)
  String get signedAmount {
    return isIncome ? '+$displayAmount' : '-$displayAmount';
  }

  /// Validates if the transaction has all required fields properly filled
  bool isValid() {
    return VALID_TYPES.contains(type) &&
        amount.isFinite &&
        description.isNotEmpty &&
        category.isNotEmpty;
  }
}
