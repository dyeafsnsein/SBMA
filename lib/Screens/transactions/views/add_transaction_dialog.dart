import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../Controllers/category_controller.dart';
import '../../../Models/category_model.dart';
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
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl =
      TextEditingController(text: widget.initialTransaction?.description);
  late final TextEditingController _amountCtrl = TextEditingController(
      text: widget.initialTransaction?.amount.abs().toString());
  late bool _isExpense = widget.initialTransaction?.type != 'income';
  late DateTime _date = widget.initialTransaction?.date ?? DateTime.now();
  String? _category;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cats = Provider.of<CategoryController>(context, listen: false)
          .expenseCategories;
      if (_isExpense &&
          (cats.isNotEmpty &&
              (_category == null || !cats.any((c) => c.label == _category)))) {
        setState(() => _category = cats.first.label);
      } else if (!_isExpense) {
        setState(() => _category = 'Income');
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _category == null) return;
    final amount = double.parse(_amountCtrl.text);
    final id = widget.initialTransaction?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final catCtrl = Provider.of<CategoryController>(context, listen: false);
    final category = _isExpense
        ? catCtrl.findCategoryByLabelOrDefault(_category!)
        : catCtrl.incomeCategories.firstWhere(
            (c) => c.label == 'Income',
            orElse: () => CategoryModel.income(
                id: 'income', label: 'Income', icon: 'lib/assets/Income.png'),
          );
    final tx = _isExpense
        ? TransactionModel.expense(
            id: id,
            amount: amount,
            date: _date,
            description: _titleCtrl.text.trim(),
            category: category.label,
            categoryId: category.id,
            icon: category.icon,
          )
        : TransactionModel.income(
            id: id,
            amount: amount,
            date: _date,
            description: _titleCtrl.text.trim(),
          );
    Navigator.of(context).pop();
    Future.microtask(() {
      (_isExpense ? widget.onAddExpense : widget.onAddIncome)(tx);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cats = _isExpense
        ? Provider.of<CategoryController>(context).expenseCategories
        : Provider.of<CategoryController>(context).incomeCategories;
    return AlertDialog(
      backgroundColor: const Color(0xFF202422),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilterChip(
                    label: const Text('Expense'),
                    selected: _isExpense,
                    onSelected: (v) => setState(() {
                      _isExpense = true;
                      _category = cats.isNotEmpty ? cats.first.label : null;
                    }),
                    selectedColor: Colors.redAccent,
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Income'),
                    selected: !_isExpense,
                    onSelected: (v) => setState(() => _isExpense = false),
                    selectedColor: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(_titleCtrl, 'Title', TextInputType.text),
              const SizedBox(height: 8),
              _buildField(_amountCtrl, 'Amount', TextInputType.number),
              const SizedBox(height: 8),
              if (_isExpense && cats.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: cats.any((c) => c.label == _category)
                      ? _category
                      : cats.first.label,
                  decoration: _dec('Category'),
                  items: cats
                      .map((c) => DropdownMenuItem(
                          value: c.label, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v),
                  dropdownColor: const Color(0xFF202422),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => v == null ? 'Select category' : null,
                ),
              if (_isExpense && cats.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(DateFormat('dd/MM/yyyy HH:mm').format(_date),
                    style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.calendar_today, color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.white30),
                ),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (d == null) return;
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_date),
                  );
                  setState(() => _date = DateTime(
                        d.year,
                        d.month,
                        d.day,
                        t?.hour ?? _date.hour,
                        t?.minute ?? _date.minute,
                      ));
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isExpense ? Colors.redAccent : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                      widget.initialTransaction != null ? 'Update' : 'Add',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String l, TextInputType t) =>
      TextFormField(
        controller: c,
        decoration: _dec(l),
        style: const TextStyle(color: Colors.white),
        keyboardType: t,
        validator: (v) => v == null || v.isEmpty ? 'Enter $l' : null,
      );
  InputDecoration _dec(String l) => InputDecoration(
        labelText: l,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      );
}
