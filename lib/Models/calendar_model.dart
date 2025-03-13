import 'package:flutter/material.dart';

class CalendarModel {
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<String> years = ['2023', '2024', '2025', '2026', '2027'];

  String selectedMonth = 'March';
  String selectedYear = '2025';
  int selectedDay = 11;
  bool showSpends = true;

  final List<Map<String, String>> transactions = [
    {
      'icon': 'lib/assets/Pantry.png',
      'title': 'Groceries',
      'time': '17:00 - March 11',
      'category': 'Pantry',
      'amount': '-\$100,00',
    },
    {
      'icon': 'lib/assets/Salary.png',
      'title': 'Others',
      'time': '17:00 - March 11',
      'category': 'Payments',
      'amount': '\$120,00',
    },
  ];

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Others',
      'percentage': 79,
      'color': Color(0xFF202422),
    },
    {
      'name': 'Groceries',
      'percentage': 10,
      'color': Color(0xFFBBBBBB),
    },
    {
      'name': 'Other',
      'percentage': 11,
      'color': Color(0xFF333333),
    },
  ];
}