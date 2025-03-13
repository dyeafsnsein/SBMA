import 'package:flutter/material.dart';

class AnalysisModel {
  final List<String> periods = ['Daily', 'Weekly', 'Monthly', 'Year'];
  int selectedPeriodIndex = 0;

  final Map<String, Map<String, dynamic>> periodData = {
    'Daily': {
      'expenses': [5.0, 3.0, 4.0, 2.0, 6.0, 3.0, 4.0],
      'income': [3.0, 5.0, 2.0, 6.0, 2.0, 1.0, 3.0],
      'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    },
    'Weekly': {
      'expenses': [8.0, 3.0, 12.0, 9.0],
      'income': [10.0, 8.0, 12.0, 9.0],
      'labels': ['1st Week', '2nd Week', '3rd Week', '4th Week'],
    },
    'Monthly': {
      'expenses': [35.0, 38.0, 32.0, 40.0, 42.0, 36.0, 45.0, 39.0, 41.0, 37.0, 43.0, 44.0],
      'income': [80.0, 85.0, 75.0, 90.0, 82.0, 78.0, 88.0, 79.0, 86.0, 77.0, 89.0, 83.0],
      'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    },
    'Year': {
      'expenses': [400.0, 420.0, 450.0, 480.0],
      'income': [900.0, 950.0, 1000.0, 1100.0],
      'labels': ['2020', '2021', '2022', '2023'],
    },
  };

  final List<Map<String, dynamic>> targets = [
    {
      'name': 'Travel',
      'progress': 0.3,
      'color': Color(0xFF00FF94),
    },
    {
      'name': 'Car',
      'progress': 0.5,
      'color': Color(0xFF00A3FF),
    },
  ];
}