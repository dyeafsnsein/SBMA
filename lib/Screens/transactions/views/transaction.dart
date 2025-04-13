import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared_components/transaction_list.dart';
import '../../../Controllers/transaction_controller.dart';
import '../../../Models/transaction_model.dart';
import '../../../shared_components/income_expense_summary.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionController(TransactionModel()),
      child: Consumer<TransactionController>(
        builder: (context, controller, child) {
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;

          // Fetch data when the page loads
          controller.fetchData();

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
                              expense: controller.totalExpense,
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
                                    : TransactionList(transactions: controller.transactions),
                              ),
                              Positioned(
                                top: 20,
                                right: 20,
                                child: GestureDetector(
                                  onTap: () => controller.pickDateRange(context),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF202422),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'lib/assets/Calendar.png',
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
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
        },
      ),
    );
  }
}