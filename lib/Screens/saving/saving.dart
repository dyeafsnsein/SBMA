import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Controllers/home_controller.dart';
import '../../Controllers/savings_controller.dart';
import '../../Models/savings_goal.dart'; // Import the SavingsGoal model

class SavingsPage extends StatefulWidget {
  const SavingsPage({Key? key}) : super(key: key);

  @override
  SavingsPageState createState() => SavingsPageState();
}

class SavingsPageState extends State<SavingsPage> {
  bool _showActiveOnly = false;
  String _sortBy = 'name';

  Future<void> _showAddOrEditGoalDialog(
    BuildContext context,
    SavingsController controller, {
    SavingsGoal? existingGoal,
  }) async {
    final TextEditingController nameController =
        TextEditingController(text: existingGoal?.name ?? '');
    final TextEditingController targetAmountController = TextEditingController(
        text: existingGoal != null ? existingGoal.targetAmount.toString() : '');
    String? selectedIcon = existingGoal?.icon;

    final List<Map<String, String>> availableIcons = [
      {'label': 'Travel', 'icon': 'lib/assets/Travel.png'},
      {'label': 'New House', 'icon': 'lib/assets/New House.png'},
      {'label': 'Car', 'icon': 'lib/assets/Car.png'},
      {'label': 'Wedding', 'icon': 'lib/assets/Wedding.png'},
    ];

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(existingGoal == null ? 'Add Savings Goal' : 'Edit Savings Goal'),
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
              onPressed: () {
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final targetAmount = double.tryParse(targetAmountController.text);

                if (name.isEmpty || targetAmount == null || targetAmount <= 0 || selectedIcon == null) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid name, target amount, and select an icon')),
                  );
                  return;
                }

                if (existingGoal == null) {
                  await controller.createSavingsGoal(
                    name: name,
                    icon: selectedIcon!,
                    targetAmount: targetAmount,
                  );
                } else {
                  await controller.updateSavingsGoal(
                    goalId: existingGoal.id,
                    name: name,
                    icon: selectedIcon!,
                    targetAmount: targetAmount,
                  );
                }

                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
              },
              child: Text(existingGoal == null ? 'Add Goal' : 'Update Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, SavingsController controller, String goalId, String goalName) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete the goal "$goalName"?'),
        actions: [
          TextButton(
            onPressed: () {
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await controller.deleteSavingsGoal(goalId);
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Goal "$goalName" deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
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

    final totalSaved = savingsController.savingsGoals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.currentAmount,
    );
    final activeGoalsCount = savingsController.savingsGoals.where((goal) => goal.isActive).length;

    List<SavingsGoal> displayedGoals = List.from(savingsController.savingsGoals)
        .whereType<SavingsGoal>()
        .toList(); // Ensure only non-null SavingsGoal objects
    if (_showActiveOnly) {
      displayedGoals = displayedGoals.where((goal) => goal.isActive).toList();
    }
    if (_sortBy == 'progress') {
      displayedGoals.sort((a, b) {
        final progressA = a.targetAmount > 0 ? a.currentAmount / a.targetAmount : 0.0;
        final progressB = b.targetAmount > 0 ? b.currentAmount / b.targetAmount : 0.0;
        return progressB.compareTo(progressA);
      });
    } else if (_sortBy == 'target') {
      displayedGoals.sort((a, b) => b.targetAmount.compareTo(a.targetAmount));
    } else {
      displayedGoals.sort((a, b) => a.name.compareTo(b.name));
    }

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
                                onTap: () {
                                  if (!mounted) return;
                                  context.pop();
                                },
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
                                  if (!mounted) return;
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBalanceInfo(
                                title: 'Total Saved',
                                amount: '\$${totalSaved.toStringAsFixed(2)}',
                              ),
                              _buildBalanceInfo(
                                title: 'Active Goals',
                                amount: '$activeGoalsCount',
                              ),
                            ],
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Filter:',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: Color(0xFF202422),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('All'),
                                    selected: !_showActiveOnly,
                                    onSelected: (selected) {
                                      setState(() {
                                        _showActiveOnly = false;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('Active'),
                                    selected: _showActiveOnly,
                                    onSelected: (selected) {
                                      setState(() {
                                        _showActiveOnly = true;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              DropdownButton<String>(
                                value: _sortBy,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'name',
                                    child: Text('Sort by Name'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'progress',
                                    child: Text('Sort by Progress'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'target',
                                    child: Text('Sort by Target'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _sortBy = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: savingsController.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : savingsController.errorMessage != null
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              savingsController.errorMessage!,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 16,
                                                color: Colors.red,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                savingsController.retryLoading();
                                              },
                                              child: const Text('Retry'),
                                            ),
                                          ],
                                        ),
                                      )
                                    : displayedGoals.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No savings goals yet. Add one to get started!',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 16,
                                                color: Color(0xFF202422),
                                              ),
                                              textAlign: TextAlign.center,
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
                                            itemCount: displayedGoals.length,
                                            itemBuilder: (context, index) {
                                              final goal = displayedGoals[index];
                                              final progress = goal.targetAmount > 0
                                                  ? goal.currentAmount / goal.targetAmount
                                                  : 0.0;
                                              return GestureDetector(
                                                onTap: () {
                                                  if (!mounted) return;
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
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('${goal.name} set as active goal')),
                                                  );
                                                },
                                                child: Stack(
                                                  children: [
                                                    Column(
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
                                                                child: Stack(
                                                                  alignment: Alignment.center,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 60,
                                                                      height: 60,
                                                                      child: CircularProgressIndicator(
                                                                        value: progress,
                                                                        backgroundColor: Colors.grey[300],
                                                                        valueColor: const AlwaysStoppedAnimation<
                                                                            Color>(Colors.green),
                                                                      ),
                                                                    ),
                                                                    Image.asset(
                                                                      goal.icon,
                                                                      width: 45,
                                                                      height: 45,
                                                                      errorBuilder: (context, error, stackTrace) =>
                                                                          const Icon(
                                                                        Icons.error,
                                                                        color: Colors.white,
                                                                        size: 45,
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                        Text(
                                                          '${(progress * 100).toStringAsFixed(1)}%',
                                                          style: const TextStyle(
                                                            fontFamily: 'Poppins',
                                                            fontSize: 10,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      left: 0,
                                                      child: GestureDetector(
                                                        onTap: () => _showAddOrEditGoalDialog(
                                                            context, savingsController,
                                                            existingGoal: goal),
                                                        child: Container(
                                                          padding: const EdgeInsets.all(2),
                                                          decoration: const BoxDecoration(
                                                            color: Colors.blue,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: const Icon(
                                                            Icons.edit,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: GestureDetector(
                                                        onTap: () => _showDeleteConfirmationDialog(
                                                            context, savingsController, goal.id, goal.name),
                                                        child: Container(
                                                          padding: const EdgeInsets.all(2),
                                                          decoration: const BoxDecoration(
                                                            color: Colors.red,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: const Icon(
                                                            Icons.delete,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                          ),
                        ],
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
                  onPressed: () => _showAddOrEditGoalDialog(context, savingsController),
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