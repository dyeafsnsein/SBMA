import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
          title: Text(
              existingGoal == null ? 'Add Savings Goal' : 'Edit Savings Goal'),
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
                final targetAmount =
                    double.tryParse(targetAmountController.text);

                if (name.isEmpty ||
                    targetAmount == null ||
                    targetAmount <= 0 ||
                    selectedIcon == null) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please enter a valid name, target amount, and select an icon')),
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

  Future<void> _showDeleteConfirmationDialog(BuildContext context,
      SavingsController controller, String goalId, String goalName) async {
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final double topSectionHeight = height * 0.32;
    final double horizontalPadding = width * 0.06;
    final double verticalPadding = height * 0.02;

    final totalSaved = savingsController.savingsGoals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.currentAmount,
    );
    final activeGoalsCount =
        savingsController.savingsGoals.where((goal) => goal.isActive).length;

    List<SavingsGoal> displayedGoals = List.from(savingsController.savingsGoals)
        .whereType<SavingsGoal>()
        .toList();
    if (_showActiveOnly) {
      displayedGoals = displayedGoals.where((goal) => goal.isActive).toList();
    }
    if (_sortBy == 'progress') {
      displayedGoals.sort((a, b) {
        final progressA =
            a.targetAmount > 0 ? a.currentAmount / a.targetAmount : 0.0;
        final progressB =
            b.targetAmount > 0 ? b.currentAmount / b.targetAmount : 0.0;
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
        body: SafeArea(
          bottom: false, // Let the container handle bottom padding
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: topSectionHeight,
                    color: const Color(0xFF202422),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
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
                                  color: Colors.white,
                                  fontSize: width * 0.06,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showAddOrEditGoalDialog(
                                      context, savingsController);
                                },
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: width * 0.06,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Saved',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.04,
                                ),
                              ),
                              Text(
                                '\$$totalSaved',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.06,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Active Goals',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.04,
                                ),
                              ),
                              Text(
                                '$activeGoalsCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.06,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: verticalPadding,
                          bottom: bottomPadding, // Add bottom padding to account for system navigation
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildFilterButton(
                                      'All',
                                      !_showActiveOnly,
                                      () => setState(
                                          () => _showActiveOnly = false),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    _buildFilterButton(
                                      'Active',
                                      _showActiveOnly,
                                      () => setState(
                                          () => _showActiveOnly = true),
                                    ),
                                  ],
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    setState(() => _sortBy = value);
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'name',
                                      child: Text('Sort by Name'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'progress',
                                      child: Text('Sort by Progress'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'target',
                                      child: Text('Sort by Target'),
                                    ),
                                  ],
                                  child: Icon(
                                    Icons.sort,
                                    size: width * 0.06,
                                    color: const Color(0xFF202422),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.02),
                            Expanded(
                              child: displayedGoals.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No savings goals yet',
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : GridView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: EdgeInsets.only(
                                        top: height * 0.02,
                                        bottom: height * 0.02, // Reduced to avoid extra space
                                      ),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: width * 0.04,
                                        mainAxisSpacing: height * 0.02,
                                        childAspectRatio: 0.75,
                                      ),
                                      itemCount: displayedGoals.length,
                                      itemBuilder: (context, index) {
                                        final goal = displayedGoals[index];
                                        final progress = goal.targetAmount > 0
                                            ? goal.currentAmount /
                                                goal.targetAmount
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
                                            await savingsController
                                                .setActiveGoal(goal.id);
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    '${goal.name} set as active goal'),
                                              ),
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
                                                        width: width * 0.2,
                                                        height: width * 0.2,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFF202422),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Center(
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              SizedBox(
                                                                width: width *
                                                                    0.15,
                                                                height: width *
                                                                    0.15,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  value:
                                                                      progress,
                                                                  backgroundColor:
                                                                      Colors.grey[
                                                                          300],
                                                                  valueColor: const AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .green),
                                                                ),
                                                              ),
                                                              Image.asset(
                                                                goal.icon,
                                                                width: width *
                                                                    0.12,
                                                                height: width *
                                                                    0.12,
                                                                errorBuilder:
                                                                    (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        Icon(
                                                                  Icons.error,
                                                                  color: Colors
                                                                      .white,
                                                                  size: width *
                                                                      0.12,
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
                                                            padding:
                                                                EdgeInsets.all(
                                                                    width *
                                                                        0.01),
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.yellow,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.black,
                                                              size:
                                                                  width * 0.04,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.01),
                                                  Text(
                                                    goal.name,
                                                    style: TextStyle(
                                                      fontSize: width * 0.035,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                          0xFF202422),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    '${(progress * 100).toStringAsFixed(1)}%',
                                                    style: TextStyle(
                                                      fontSize: width * 0.03,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _showAddOrEditGoalDialog(
                                                    context,
                                                    savingsController,
                                                    existingGoal: goal,
                                                  ),
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        width * 0.01),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.blue,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: Colors.white,
                                                      size: width * 0.04,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _showDeleteConfirmationDialog(
                                                    context,
                                                    savingsController,
                                                    goal.id,
                                                    goal.name,
                                                  ),
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        width * 0.01),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.white,
                                                      size: width * 0.04,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF202422) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF202422),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF202422),
            fontSize: MediaQuery.of(context).size.width * 0.035,
          ),
        ),
      ),
    );
  }
}
