import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/savings_controller.dart';
import '../../Models/savings_goal.dart';

class SavingsAnalysisPage extends StatefulWidget {
  final String categoryName;
  final String iconPath;
  final String goalId;

  const SavingsAnalysisPage({
    Key? key,
    required this.categoryName,
    required this.iconPath,
    required this.goalId,
  }) : super(key: key);

  @override
  _SavingsAnalysisPageState createState() => _SavingsAnalysisPageState();
}

class _SavingsAnalysisPageState extends State<SavingsAnalysisPage> {
  Future<void> _showAddDepositDialog(
      BuildContext context, SavingsController controller) async {
    final TextEditingController amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Deposit to ${widget.categoryName}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid amount')),
                  );
                }
                return;
              }

              await controller.addDeposit(widget.goalId, amount);
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Deposit of \$${amount.toStringAsFixed(2)} added')),
                );
              }
            },
            child: const Text('Add Deposit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SavingsController>(context);
    final goal = controller.savingsGoals.firstWhere(
      (g) => g.id == widget.goalId,
      orElse: () => SavingsGoal(
        id: widget.goalId,
        name: widget.categoryName,
        icon: widget.iconPath,
        targetAmount: 0.0,
        currentAmount: 0.0,
        isActive: false,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              color: const Color(0xFF202422),
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    widget.categoryName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF050505),
                      borderRadius: BorderRadius.circular(25.71),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 600,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Goal',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF202422),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${goal.targetAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF202422),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Amount Saved',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF202422),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${goal.currentAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF202422),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                  value: 0.0,
                                  strokeWidth: 3,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              Image.asset(widget.iconPath,
                                  width: 40, height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Deposits list',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF202422),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<Deposit>>(
                      stream: controller.depositsStream(widget.goalId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading deposits'));
                        }
                        final deposits = snapshot.data ?? [];
                        if (deposits.isEmpty) {
                          return const Center(child: Text('No deposits yet'));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: deposits.length,
                          itemBuilder: (context, index) {
                            final deposit = deposits[index];
                            return _buildSavingsItemWithIcon(
                              'Deposit',
                              '${deposit.timestamp.toString().split(' ')[0]} ${deposit.timestamp.toString().split(' ')[1].substring(0, 5)}',
                              '\$${deposit.amount.toStringAsFixed(2)}',
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _showAddDepositDialog(context, controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Add Savings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildSavingsItemWithIcon(
      String title, String subtitle, String amount) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            Center(child: Image.asset(widget.iconPath, width: 20, height: 20)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF202422),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
      ),
      trailing: Text(
        amount,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF202422),
        ),
      ),
    );
  }
}
