class HomeModel {
  int selectedPeriodIndex = 2;

  final List<String> periods = ['Daily', 'Weekly', 'Monthly'];

  final List<Map<String, String>> transactions = [
    {
      'icon': 'lib/assets/Salary.png',
      'time': '18:27 - April 30',
      'category': 'Monthly',
      'amount': '\$4,000.00',
    },
    {
      'icon': 'lib/assets/Pantry.png',
      'time': '17:00 - April 24',
      'category': 'Pantry',
      'amount': '-\$100.00',
    },
    {
      'icon': 'lib/assets/Rent.png',
      'time': '8:30 - April 15',
      'category': 'Rent',
      'amount': '-\$874.40',
    },
    {
      'icon': 'lib/assets/Rent.png',
      'time': '9:30 - April 25',
      'category': 'Rent',
      'amount': '-\$774.40',
    },
    {
      'icon': 'lib/assets/Rent.png',
      'time': '9:30 - April 25',
      'category': 'Rent',
      'amount': '-\$774.40',
    },
    {
      'icon': 'lib/assets/Pantry.png',
      'time': '17:00 - April 24',
      'category': 'Pantry',
      'amount': '-\$100.00',
    },
    {
      'icon': 'lib/assets/Pantry.png',
      'time': '18:00 - April 24',
      'category': 'Pantry',
      'amount': '-\$100.00',
    },
  ];
}