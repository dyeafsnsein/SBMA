import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Controllers/search_controller.dart' as custom;

class CategoriesDropdown extends StatelessWidget {
  const CategoriesDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<custom.SearchController>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF202422),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F9E9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select the category'),
              value: controller.selectedCategory,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: controller.categories.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                controller.setSelectedCategory(newValue);
              },
            ),
          ),
        ),
      ],
    );
  }
}