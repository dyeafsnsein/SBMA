import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../Controllers/home_controller.dart';
import '../../Controllers/savings_controller.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({Key? key}) : super(key: key);

  @override
  _SavingsPageState createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  Future<void> _showAddGoalDialog(BuildContext context, SavingsController controller) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController targetAmountController = TextEditingController();
    String? selectedIcon;

    final List<Map<String, String>> availableIcons = [
      {'label': 'Travel', 'icon': 'lib/assets/Travel.png'},
      {'label': 'New House', 'icon': 'lib/assets/New House.png'},
      {'label': 'Car', 'icon': 'lib/assets/Car.png'},
      {'label': 'Wedding', 'icon': 'lib/assets/Wedding.png'},
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Savings Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: targetAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Icon',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedIcon,
                  items: availableIcons.map((icon) {
                    return DropdownMenuItem<String>(
                      value: icon['icon'],
                      child: Text(icon['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedIcon = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final targetAmount = double.tryParse(targetAmountController.text);

                if (name.isEmpty || targetAmount == null || targetAmount <= 0 || selectedIcon == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid name, target amount, and select an icon')),
                    );
                  }
                  return;
                }

                await controller.createSavingsGoal(
                  name: name,
                  icon: selectedIcon!,
                  targetAmount: targetAmount,
                );

                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context);
    final savingsController = Provider.of<SavingsController>(context);
    final Size screenSize = MediaQuery.of(context).size;
    final double paddingTop = MediaQuery.of(context).padding.top;
    final double height = screenSize.height;
    final double width = screenSize.width;

    final double topSectionHeight = height * 0.32;
    final double horizontalPadding = width * 0.06;
    final double verticalPadding = height * 0.02;

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
                  height: topSectionHeight,
                  child: Container(
                    color: const Color(0xFF202422),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        paddingTop + verticalPadding,
                        horizontalPadding,
                        verticalPadding,
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
                              Text(
                                'Savings',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: width * 0.06,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.push('/notification');
                                },
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBalanceInfo(
                                title: 'Total Balance',
                                amount: '\$${homeController.totalBalance.toStringAsFixed(2)}',
                              ),
                              _buildBalanceInfo(
                                title: 'Total Expense',
                                amount: '-\$${homeController.totalExpense.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [],
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
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                      child: savingsController.savingsGoals.isEmpty
                          ? const Center(
                              child: Text(
                                'No savings goals available',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Color(0xFF202422),
                                ),
                              ),
                            )
                          : GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(top: 20, bottom: 80),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: savingsController.savingsGoals.length,
                              itemBuilder: (context, index) {
                                final goal = savingsController.savingsGoals[index];
                                return GestureDetector(
                                  onTap: () {
                                    context.push(
                                      '/savings-analysis',
                                      extra: {
                                        'categoryName': goal.name,
                                        'iconPath': goal.icon,
                                        'goalId': goal.id,
                                      },
                                    );
                                  },
                                  onLongPress: () async {
                                    await savingsController.setActiveGoal(goal.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${goal.name} set as active goal')),
                                      );
                                    }
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF202422),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                goal.icon,
                                                width: 45,
                                                height: 45,
                                                errorBuilder: (context, error, stackTrace) => const Icon(
                                                  Icons.error,
                                                  color: Colors.white,
                                                  size: 45,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (goal.isActive)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: Colors.yellow,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.star,
                                                  color: Colors.black,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        goal.name,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF202422),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: height * 0.12,
              left: width * 0.05,
              right: width * 0.05,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => _showAddGoalDialog(context, savingsController),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF202422),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.015,
                      horizontal: width * 0.06,
                    ),
                    minimumSize: Size(width * 0.3, height * 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Add More',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfo({required String title, required String amount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}