import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Home.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.notifications_outlined,
      'title': 'Reminder!',
      'message': 'Set up your automatic savings to meet your savings goal...',
      'time': '17:00 - April 24',
    },
    {
      'icon': Icons.star_outline,
      'title': 'New Update',
      'message': 'Set up your automatic savings to meet your savings goal...',
      'time': '17:00 - April 24',
    },
    {
      'icon': Icons.attach_money,
      'title': 'Transactions',
      'message': 'A new transaction has been registered\nGroceries | Pantry | -\$100,00',
      'time': '17:00 - April 24',
    },
    {
      'icon': Icons.notifications_outlined,
      'title': 'Reminder!',
      'message': 'Set up your automatic savings to meet your savings goal...',
      'time': '17:00 - April 24',
    },
    {
      'icon': Icons.access_time,
      'title': 'Expense Record',
      'message': 'We recommend that you be more attentive to your finances.',
      'time': '17:00 - April 24',
    },
    {
      'icon': Icons.attach_money,
      'title': 'Transactions',
      'message': 'A new transaction has been registered\nFood | Dinner | -\$70,40',
      'time': '17:00 - April 24',
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
      // Navigate to Home page when the home button is tapped
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
                  flex: 16,
                  child: Container(
                    color: const Color(0xFF202422),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 60, 25, 10),
                      child: Row(
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
                            'Notification',
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
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index == 0) const Text('Today'),
                              if (index == 2) const Text('Yesterday'),
                              if (index == 4) const Text('This Weekend'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF202422),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        notification['icon'] as IconData,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification['title']!,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF202422),
                                          ),
                                        ),
                                        Text(
                                          notification['message']!,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF202422),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    notification['time']!,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF202422),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color(0xFF202422),
                                thickness: 1,
                                height: 20,
                              ),
                            ],
                          );
                        },
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
