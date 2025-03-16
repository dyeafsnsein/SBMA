import 'package:flutter/material.dart';

class CalendarPicker extends StatelessWidget {
  final Function(DateTimeRange?) onDateRangeSelected;

  const CalendarPicker({Key? key, required this.onDateRangeSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDateRange(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            'lib/assets/Calendar.png',
            width: 20,
            height: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF202422),
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF202422),
              secondary: const Color(0xFF0D4015),
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(picked);
    }
  }
}
