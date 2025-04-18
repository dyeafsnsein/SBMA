import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../Controllers/category_controller.dart';
import '../Models/category_model.dart';
import '../Models/transaction_model.dart';

class AddTransactionDialog extends StatefulWidget {
  final Function(TransactionModel) onAddExpense;
  final Function(TransactionModel) onAddIncome;

  const AddTransactionDialog({
    Key? key,
    required this.onAddExpense,
    required this.onAddIncome,
  }) : super(key: key);

  @override
  AddTransactionDialogState createState() => AddTransactionDialogState();
}

class AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDateTime = DateTime.now();
  bool _isExpense = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    } else {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final categoryController = Provider.of<CategoryController>(context, listen: false);
        final selectedCategoryData = categoryController.categories.firstWhere(
          (category) => category.label == _selectedCategory,
          orElse: () =>  CategoryModel(
            id: 'unknown',
            label: 'Unknown',
            icon: 'lib/assets/Transaction.png',
          ),
        );

        final transaction = TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
          type: _isExpense ? 'expense' : 'income',
          amount: double.parse(_amountController.text),
          date: _selectedDateTime,
          description: _titleController.text,
          category: selectedCategoryData.label,
          categoryId: selectedCategoryData.id,
          icon: selectedCategoryData.icon,
        );

        if (_isExpense) {
          widget.onAddExpense(transaction);
        } else {
          widget.onAddIncome(transaction);
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Provider.of<CategoryController>(context);
    final filteredCategories = categoryController.categories
        .where((category) => category.label != 'More')
        .toList();

    if (_selectedCategory == null && filteredCategories.isNotEmpty) {
      _selectedCategory = filteredCategories.first.label;
    }

    final screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      backgroundColor: const Color(0xFF202422),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: filteredCategories.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Expense'),
                          selected: _isExpense,
                          onSelected: (selected) {
                            setState(() {
                              _isExpense = true;
                            });
                          },
                          selectedColor: Colors.redAccent,
                          backgroundColor: Colors.grey,
                          labelStyle: TextStyle(
                            color: _isExpense ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Income'),
                          selected: !_isExpense,
                          onSelected: (selected) {
                            setState(() {
                              _isExpense = false;
                            });
                          },
                          selectedColor: Colors.greenAccent,
                          backgroundColor: Colors.grey,
                          labelStyle: TextStyle(
                            color: !_isExpense ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _amountController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date & Time: ${_formatDateTime(_selectedDateTime)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                            const Icon(
                              CupertinoIcons.calendar,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isExpense)
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                        dropdownColor: const Color(0xFF202422),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                        menuMaxHeight: screenHeight * 0.3,
                        items: filteredCategories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.label,
                            child: Row(
                              children: [
                                Image.asset(
                                  category.icon,
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.category,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          }
                        },
                      ),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _submitForm(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D4015),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}