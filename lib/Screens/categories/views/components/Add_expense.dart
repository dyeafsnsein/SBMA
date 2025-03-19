import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddExpensesPage extends StatefulWidget {
  final String categoryName;
  final Function(Map<String, String>) onSave;

  const AddExpensesPage({
    Key? key,
    required this.categoryName,
    required this.onSave,
  }) : super(key: key);

  @override
  _AddExpensesPageState createState() => _AddExpensesPageState();
}

class _AddExpensesPageState extends State<AddExpensesPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String selectedCategory = 'Food';
  String selectedDate = 'April 30, 2024';

  @override
  Widget build(BuildContext context) {
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
                // Top Section (Header)
                Expanded(
                  flex: 12,
                  child: Container(
                    color: const Color(0xFF202422),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 60, 25, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Add Expenses',
                            style: TextStyle(
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
                  ),
                ),

                // Bottom Section (Form Fields)
                Expanded(
                  flex: 88,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Picker Field
                          Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: selectedDate,
                                hintStyle: const TextStyle(color: Colors.grey),
                                suffixIcon: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF202422),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    selectedDate =
                                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Category Dropdown
                          Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hintText: 'Select the category',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFF202422),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              value: selectedCategory,
                              items:
                                  ['Food', 'Travel', 'Work', 'Leisure']
                                      .map(
                                        (category) => DropdownMenuItem<String>(
                                          value: category,
                                          child: Text(
                                            category,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Amount Field
                          Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '\$26,00',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFF202422),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Expense Title Field
                          Text(
                            'Expense Title',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                hintText: 'Dinner',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFF202422),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Message Field
                          Text(
                            'Enter Message',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextField(
                              controller: messageController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Enter your message here',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFF202422),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Create a new expense object
                                final newExpense = {
                                  'icon': 'lib/assets/Food.png',
                                  'time': '18:27',
                                  'category': selectedCategory,
                                  'amount': '-${amountController.text}',
                                  'date': selectedDate,
                                  'title': titleController.text,
                                  'message': messageController.text,
                                };

                                // Debug the new expense
                                print('New Expense: $newExpense');

                                // Pass the new expense back to the Category Template page
                                widget.onSave(newExpense);

                                // Close the Add Expense page
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
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
