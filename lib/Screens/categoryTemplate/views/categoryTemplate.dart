import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../shared_components/progress_bar.dart';
import '../../../shared_components/transaction_list.dart';
import '../../../shared_components/balance_overview.dart';
import '../../categories/views/components/Add_expense.dart';
import '../../../Models/transaction_model.dart';

class CategoryTemplatePage extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;

  const CategoryTemplatePage({
    Key? key,
    required this.categoryName,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  State<CategoryTemplatePage> createState() => _CategoryTemplatePageState();
}

class _CategoryTemplatePageState extends State<CategoryTemplatePage> {
  final RxList<TransactionModel> _transactions = <TransactionModel>[].obs;
  final RxList<TransactionModel> _allTransactions = <TransactionModel>[].obs;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() {
    _allTransactions.value = [
      TransactionModel(
        type: 'expense',
        amount: -26.00,
        date: DateTime(2025, 4, 30),
        description: 'Dinner',
        category: 'Food',
        icon: 'lib/assets/Food.png',
      ),
    ];
    _transactions.value = List.from(_allTransactions);
  }

  void _addNewExpense(Map<String, String> newExpense) {
    final transaction = TransactionModel(
      type: 'expense',
      amount: double.parse(newExpense['amount'] ?? '0'),
      date: DateTime.parse(newExpense['date'] ?? DateTime.now().toString()),
      description: newExpense['description'] ?? '',
      category: newExpense['category'] ?? '',
      icon: newExpense['icon'] ?? 'lib/assets/Transaction.png',
    );

    _allTransactions.add(transaction);
    _transactions.value = List.from(_allTransactions);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double paddingTop = MediaQuery.of(context).padding.top;
    final double height = screenSize.height;
    final double width = screenSize.width;

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
                SizedBox(
                  height: height * 0.32,
                  child: Container(
                    color: const Color(0xFF202422),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        width * 0.06,
                        paddingTop + height * 0.02,
                        width * 0.06,
                        height * 0.02,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: width * 0.06,
                                ),
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    widget.categoryIcon,
                                    width: 24,
                                    height: 24,
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Text(
                                    widget.categoryName,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: width * 0.06,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => context.push('/notification'),
                                child: Container(
                                  width: width * 0.08,
                                  height: width * 0.08,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF050505),
                                    borderRadius: BorderRadius.circular(
                                      width * 0.04,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                      size: width * 0.05,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const BalanceOverview(
                            totalBalance: 7783.00,
                            totalExpense: 1187.40,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProgressBar(
                                  progress: 0.3,
                                  goalAmount: 20000.00,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_box,
                                      color: Colors.white,
                                      size: width * 0.04,
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Text(
                                      '30% Of Your Expenses, Looks Good.',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: width * 0.035,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Expanded(
                            child: Obx(() => _transactions.isEmpty
                                ? const Center(
                                    child: Text('No transactions available'),
                                  )
                                : TransactionList(transactions: _transactions)),
                          ),
                        ],
                      ),
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
