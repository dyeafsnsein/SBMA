class SearchModel {
  DateTime selectedDate = DateTime.now();
  String? selectedCategory;
  bool isIncome = false;
  bool isExpense = true;

  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Education',
    'Other'
  ];
}