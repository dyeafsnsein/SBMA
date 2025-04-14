import 'package:flutter/material.dart';

class SavingsAnalysisPage extends StatelessWidget {
  final String categoryName;
  final String iconPath;

  const SavingsAnalysisPage({
    Key? key,
    required this.categoryName,
    required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Enables smooth scrolling
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevent unnecessary stretching
          children: [
            // Top Section (Header)
            Container(
              height: 120,
              color: const Color(0xFF202422),
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    categoryName,
                    style: const TextStyle(
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

            const SizedBox(height: 20),

            // Content Section
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 600, // Ensures the container expands properly
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Allows content to wrap
                  children: [
                    // Goal & Amount Saved Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Goal and Amount Saved
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Goal',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF202422),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '\$1,962.93',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF202422),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Amount Saved',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF202422),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '\$653.31',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF202422),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Black Box with Circular Progress and Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: 0.3, // 30% progress
                                  strokeWidth: 3,
                                  backgroundColor: Colors.white,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.green,
                                      ),
                                ),
                              ),
                              Image.asset(iconPath, width: 40, height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Progress Bar
                 

                    const SizedBox(height: 20),

                    // Month and Calendar Picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'April',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF202422),
                          ),
                        ),
                    
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Savings Deposits
                    _buildSavingsItemWithIcon(
                      'Travel Deposit',
                      '19:56 - April 30',
                    ),
                    _buildSavingsItemWithIcon(
                      'Travel Deposit',
                      '17:42 - April 14',
                    ),
                    _buildSavingsItemWithIcon(
                      'Travel Deposit',
                      '12:30 - April 02',
                    ),

                    const SizedBox(height: 15),

                    // Add Savings Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle adding savings
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Add Savings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Savings Item
  Widget _buildSavingsItemWithIcon(String title, String subtitle) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Image.asset(iconPath, width: 20, height: 20)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF202422),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
      ),
    );
  }
}
