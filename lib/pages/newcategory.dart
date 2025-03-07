import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NewCategory extends StatefulWidget {
  final Function(String) onSave;

  const NewCategory({Key? key, required this.onSave}) : super(key: key);

  @override
  State<NewCategory> createState() => _NewCategoryState();
}

class _NewCategoryState extends State<NewCategory> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'New Category',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202422),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF202422),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextFormField(
                  controller: _categoryController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write...',
                    hintStyle: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    errorStyle: TextStyle(
                      color: Colors.red,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF202422),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave(_categoryController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFD3D3D3),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.black,
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
