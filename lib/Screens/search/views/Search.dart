import 'package:flutter/material.dart' hide SearchController;
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/search_controller.dart' as custom;
import '../../../Models/search_model.dart';
import '../../../Route/app_router.dart'; // Adjust the import path as necessary
import 'components/SearchField.dart';
import 'components/CategoriesDropdown.dart';
import 'components/DatePicker.dart';
import 'components/ReportOptions.dart';

@RoutePage()
class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => custom.SearchController(SearchModel()),
      child: Consumer<custom.SearchController>(
        builder: (context, controller, child) {
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;

          return Scaffold(
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
                          vertical: screenHeight * 0.04,
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
                              'Search',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.router.push(const NotificationRoute());
                              },
                              child: Container(
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
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Search field
                    SearchField(controller: TextEditingController()),
                    
                    // Main content
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: screenHeight * 0.02),
                        padding: EdgeInsets.all(screenWidth * 0.06),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1FFF3),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Categories
                              const CategoriesDropdown(),
                              
                              // Date
                              const DatePicker(),
                              
                              // Report
                              const ReportOptions(),
                              
                              // Search button
                              SizedBox(height: screenHeight * 0.05),
                              Center(
                                child: SizedBox(
                                  width: screenWidth * 0.5,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Implement search functionality
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF202422),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: const Text(
                                      'Search',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
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
          );
        },
      ),
    );
  }
}