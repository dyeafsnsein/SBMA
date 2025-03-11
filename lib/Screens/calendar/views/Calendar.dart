import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import '../../../shared_components/transaction_list.dart';
import '../../../shared_components/CalenderPieChart.dart';

@RoutePage()
class CalendarPage extends StatefulWidget {
const CalendarPage({Key? key}) : super(key: key);

@override
State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {


final List<String> _months = [
'January', 'February', 'March', 'April', 'May', 'June',
'July', 'August', 'September', 'October', 'November', 'December'
];

final List<String> _years = ['2023', '2024', '2025', '2026', '2027'];

String _selectedMonth = 'March';
String _selectedYear = '2025';
int _selectedDay = 11;
bool _showSpends = true;

// For TransactionList
final List<Map<String, String>> _transactions = [
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

// For CategoryPieChart
final List<Map<String, dynamic>> _categories = [
{
'name': 'Others',
'percentage': 79,
'color': const Color(0xFF202422),
},
{
'name': 'Groceries',
'percentage': 10,
'color': const Color(0xFFBBBBBB),
},
{
'name': 'Other',
'percentage': 11,
'color': const Color(0xFF333333),
},
];

@override
Widget build(BuildContext context) {
final screenHeight = MediaQuery.of(context).size.height;
final screenWidth = MediaQuery.of(context).size.width;

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
                // Header
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.06,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Calender',
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
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Main content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        children: [
                          // Month and Year selectors
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDropdown(_selectedMonth, _months, (value) {
                                setState(() {
                                  _selectedMonth = value!;
                                });
                              }),
                              _buildDropdown(_selectedYear, _years, (value) {
                                setState(() {
                                  _selectedYear = value!;
                                });
                              }),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Calendar grid
                          _buildCalendarGrid(),
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Tabs
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showSpends = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _showSpends ? const Color(0xFF202422) : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Spends',
                                        style: TextStyle(
                                          color: _showSpends ? Colors.white : Colors.black,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showSpends = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_showSpends ? const Color(0xFF202422) : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Categories',
                                        style: TextStyle(
                                          color: !_showSpends ? Colors.white : Colors.black,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Conditional rendering based on selected tab
                          Expanded(
                            child: _showSpends 
                              ? TransactionList(transactions: _transactions)
                              : CategoryPieChart(categories: _categories),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        
          ],
        ),
      ),
    );
    }

Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
decoration: BoxDecoration(
color: Colors.transparent,
borderRadius: BorderRadius.circular(10),
),
child: DropdownButton<String>(
value: value,
icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF202422)),
underline: const SizedBox(),
style: const TextStyle(
color: Color(0xFF202422),
fontFamily: 'Poppins',
fontWeight: FontWeight.w600,
fontSize: 16,
),
onChanged: onChanged,
items: items.map<DropdownMenuItem<String>>((String value) {
return DropdownMenuItem<String>(
value: value,
child: Text(value),
);
}).toList(),
),
);
}

Widget _buildCalendarGrid() {
final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Days of week header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysOfWeek.map((day) => Text(
            day,
            style: const TextStyle(
              color: Color(0xFF202422),
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),
        
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: 31, // March has 31 days
          itemBuilder: (context, index) {
            final day = index + 1;
            final isSelected = day == _selectedDay;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = day;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isSelected ? const Color.fromARGB(255, 93, 208, 250) : Colors.transparent,
                ),
                 
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color.fromARGB(255, 93, 208, 250),
                      fontFamily: 'Poppins',
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
    }

}