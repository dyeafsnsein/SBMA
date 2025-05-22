import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../Controllers/category_controller.dart';
import '../../../Models/transaction_model.dart';

class AddTransactionDialog extends StatefulWidget {
  final Function(TransactionModel) onAddExpense;
  final Function(TransactionModel) onAddIncome;
  final TransactionModel? initialTransaction;

  const AddTransactionDialog({
    Key? key,
    required this.onAddExpense,
    required this.onAddIncome,
    this.initialTransaction,
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

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      final transaction = widget.initialTransaction!;
      _titleController.text = transaction.description;
      _amountController.text = transaction.amount.abs().toString();
      _selectedCategory = transaction.category;
      _selectedDateTime = transaction.date;
      _isExpense = transaction.type == 'expense';
    }
    // Validate _selectedCategory after categories are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCategory();
    });
  }

  void _initializeCategory() {
    if (!mounted) return;
    
    final categoryController =
        Provider.of<CategoryController>(context, listen: false);
    
    if (_isExpense) {
      final expenseCategories = categoryController.expenseCategories;
      if (expenseCategories.isEmpty) return;
      
      // Only update if the current category is invalid
      final isCurrentCategoryValid = _selectedCategory != null &&
          expenseCategories.any((c) => c.label == _selectedCategory);
      
      if (!isCurrentCategoryValid) {
        setState(() {
          _selectedCategory = expenseCategories.first.label;
        });
      }
    } else {
      // For income, always use 'Income' category
      setState(() {
        _selectedCategory = 'Income';
      });
    }
  }

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

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? _selectedDateTime.hour,
        pickedTime?.minute ?? _selectedDateTime.minute,
      );
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  void _submitForm() {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoryController = Provider.of<CategoryController>(context, listen: false);
      final amount = double.parse(_amountController.text);
      final id = widget.initialTransaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      // Get category from controller
      final category = _isExpense 
          ? categoryController.findCategoryByLabelOrDefault(_selectedCategory!)
          : categoryController.getIncomeCategoryOrDefault();
      
      // Call the appropriate callback with the transaction
      if (_isExpense) {
        widget.onAddExpense(TransactionModel.expense(
          id: id,
          amount: amount,
          date: _selectedDateTime,
          description: _titleController.text,
          category: category.label,
          categoryId: category.id,
          icon: category.icon,
        ));
      } else {
        widget.onAddIncome(TransactionModel.income(
          id: id,
          amount: amount,
          date: _selectedDateTime,
          description: _titleController.text,
        ));
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

  @override
  Widget build(BuildContext context) {
    final categoryController = Provider.of<CategoryController>(context);
    final filteredCategories = _isExpense 
        ? categoryController.expenseCategories
        : categoryController.incomeCategories;

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.79;

    return AlertDialog(
      backgroundColor: const Color(0xFF202422),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: filteredCategories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Expense'),
                              selected: _isExpense,
                              onSelected: (_) {
                                setState(() {
                                  _isExpense = true;
                                  _initializeCategory(); 
                                });
                              },
                              selectedColor: Colors.redAccent,
                              backgroundColor: Colors.grey,
                              labelStyle: TextStyle(
                                color: _isExpense ? Colors.white : Colors.black,
                              ),
                            ),
                            ChoiceChip(
                              label: const Text('Income'),
                              selected: !_isExpense,
                              onSelected: (_) {
                                setState(() {
                                  _isExpense = false;
                                  _selectedCategory = 'Income';
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
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickDateTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Date & Time: ${_formatDateTime(_selectedDateTime)}',
                                  style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Only show category dropdown for expenses
                      if (_isExpense)
                      DropdownButtonFormField<String>(
                        value: filteredCategories.any((c) => c.label == _selectedCategory) 
                            ? _selectedCategory 
                            : (filteredCategories.isNotEmpty ? filteredCategories.first.label : null),
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
                        style: const TextStyle(color: Colors.white),
                        items: filteredCategories.isEmpty
                            ? [const DropdownMenuItem<String>(
                                value: 'loading',
                                enabled: false,
                                child: Text('Loading...'),
                              )]
                            : filteredCategories
                                .map((category) => DropdownMenuItem<String>(
                                  value: category.label,
                                  child: Text(category.label),
                                ))
                                .toList(),
                        onChanged: filteredCategories.isEmpty
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                        validator: (value) => _isExpense && (value == null || value.isEmpty)
                            ? 'Please select a category'
                            : null,
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading || filteredCategories.isEmpty
                              ? null
                              : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isExpense ? Colors.redAccent : Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  widget.initialTransaction != null ? 'Update' : 'Add',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
