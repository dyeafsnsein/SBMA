import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Home.dart';

class QuickAnalysis extends StatefulWidget {
  const QuickAnalysis({Key? key}) : super(key: key);

  @override
  State<QuickAnalysis> createState() => _QuickAnalysisState();
}

class _QuickAnalysisState extends State<QuickAnalysis> {
  final List<Map<String, String>> _transactions = [
    {
      'icon': 'lib/pages/assets/Salary.png',
      'title': 'Salary',
      'time': '18:27 - April 30',
      'category': 'Monthly',
      'amount': '\$4,000.00',
    },
    {
      'icon': 'lib/pages/assets/Pantry.png',
      'title': 'Groceries',
      'time': '17:00 - April 24',
      'category': 'Pantry',
      'amount': '-\$100.00',
    },
    {
      'icon': 'lib/pages/assets/Rent.png',
      'title': 'Rent',
      'time': '8:30 - April 15',
      'category': 'Rent',
      'amount': '-\$674.40',
    },
  ];

  final List<String> _iconPaths = [
    'lib/pages/assets/Home.png',
    'lib/pages/assets/Analysis.png',
    'lib/pages/assets/Transactions.png',
    'lib/pages/assets/Categories.png',
    'lib/pages/assets/Profile.png',
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF202422),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 38,
                  child: Container(
                    color: const Color(0xFF202422),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 60, 25, 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Quickly Analysis',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF050505),
                                  borderRadius: BorderRadius.circular(25.71),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(18.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF202422),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 71,
                                          height: 71,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF6DB6FE),
                                              width: 3.25,
                                            ),
                                          ),
                                        ),
                                        Image.asset(
                                          'lib/pages/assets/Car.png',
                                          width: 37.57,
                                          height: 21.75,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Savings On Goals',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFFCFCFC),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 108,
                                  color: const Color(0xFFFCFCFC),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'lib/pages/assets/Salary.png',
                                          width: 31,
                                          height: 28,
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Revenue Last Week',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: Color(0xFFFCFCFC),
                                              ),
                                            ),
                                            Text(
                                              '\$4,000.00',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFFCFCFC),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'lib/pages/assets/Food.png',
                                          width: 31,
                                          height: 28,
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Food Last Week',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: Color(0xFFFCFCFC),
                                              ),
                                            ),
                                            Text(
                                              '-\$100.00',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFFCFCFC),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 84,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF202422),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Center(
                              child: Text(
                                'Chart Coming Soon',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = _transactions[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 57,
                                        height: 53,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF202422),
                                          borderRadius: BorderRadius.circular(28.5),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            transaction['icon']!,
                                            width: 31,
                                            height: 28,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction['title']!,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF202422),
                                            ),
                                          ),
                                          Text(
                                            transaction['time']!,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF202422),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        transaction['amount']!,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF202422),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
                child: Container(
                  height: 80,
                  color: const Color(0xFF202422),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_iconPaths.length, (index) {
                      final isSelected = _selectedIndex == index;
                      return GestureDetector(
                        onTap: () => _onItemTapped(index),
                        child: Container(
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: Colors.grey[700],
                                  borderRadius: BorderRadius.circular(20),
                                )
                              : null,
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                          child: Image.asset(
                            _iconPaths[index],
                            width: 26,
                            height: 26,
                            color: isSelected ? Colors.white : const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
