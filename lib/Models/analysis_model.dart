class AnalysisModel {
  final List<String> periods = ['Daily', 'Weekly', 'Monthly', 'Year'];
  int selectedPeriodIndex = 0;

  // Define the structure for periodData, but it will be populated dynamically
  Map<String, Map<String, dynamic>> periodData = {
    'Daily': {
      'expenses': <double>[],
      'income': <double>[],
      'labels': <String>[]
    },
    'Weekly': {
      'expenses': <double>[],
      'income': <double>[],
      'labels': <String>[]
    },
    'Monthly': {
      'expenses': <double>[],
      'income': <double>[],
      'labels': <String>[]
    },
    'Year': {
      'expenses': <double>[],
      'income': <double>[],
      'labels': <String>[]
    },
  };
}
