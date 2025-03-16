import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../shared_components/transaction_list.dart';
import '../../../shared_components/CalenderPieChart.dart';
import '../../../Controllers/calendar_controller.dart';
import '../../../Models/calendar_model.dart';
import 'package:go_router/go_router.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarController(CalendarModel()),
      child: Consumer<CalendarController>(
        builder: (context, controller, child) {
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFF202422),
              body: Column(
                children: [
                  // Header
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.01,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: screenWidth * 0.06,
                            ),
                          ),
                          Text(
                            'Calendar',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/notification'),
                            child: Container(
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.08,
                              decoration: BoxDecoration(
                                color: const Color(0xFF050505),
                                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                              ),
                              child: Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: screenWidth * 0.05,
                              ),
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
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            children: [
                              // Month and Year selectors
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildDropdown(controller.selectedMonth, controller.months, (value) {
                                    controller.setSelectedMonth(value!);
                                  }),
                                  _buildDropdown(controller.selectedYear, controller.years, (value) {
                                    controller.setSelectedYear(value!);
                                  }),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              
                              // Calendar grid
                              _buildCalendarGrid(controller, screenHeight, screenWidth),
                              
                              // Tabs
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTab(
                                      title: 'Spends',
                                      isSelected: controller.showSpends,
                                      onTap: () => controller.toggleShowSpends(true),
                                      screenHeight: screenHeight,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Expanded(
                                    child: _buildTab(
                                      title: 'Categories',
                                      isSelected: !controller.showSpends,
                                      onTap: () => controller.toggleShowSpends(false),
                                      screenHeight: screenHeight,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              
                              // Content container
                              SizedBox(
                                height: screenHeight * 0.4,
                                child: controller.showSpends 
                                  ? TransactionList(transactions: controller.transactions)
                                  : CategoryPieChart(categories: controller.categories),
                              ),
                              SizedBox(height: screenHeight * 0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required double screenHeight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF202422) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
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

  Widget _buildCalendarGrid(CalendarController controller, double screenHeight, double screenWidth) {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysOfWeek.map((day) => Text(
            day,
            style: TextStyle(
              color: const Color(0xFF202422),
              fontFamily: 'Poppins',
              fontSize: screenWidth * 0.035,
            ),
          )).toList(),
        ),
        SizedBox(height: screenHeight * 0.01),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
            crossAxisSpacing: screenWidth * 0.01,
            mainAxisSpacing: screenWidth * 0.01,
          ),
          itemCount: 31,
          itemBuilder: (context, index) {
            final day = index + 1;
            final isSelected = day == controller.selectedDay;
            
            return GestureDetector(
              onTap: () => controller.setSelectedDay(day),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  color: isSelected 
                    ? const Color.fromARGB(255, 93, 208, 250) 
                    : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected 
                        ? Colors.white 
                        : const Color.fromARGB(255, 93, 208, 250),
                      fontFamily: 'Poppins',
                      fontSize: screenWidth * 0.035,
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