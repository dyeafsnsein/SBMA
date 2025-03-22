import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared_components/custom_header.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({Key? key}) : super(key: key);

  @override
  _HelpCenterState createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  int _selectedTabIndex = 0; // FAQ or Contact Us
  int _selectedCategoryIndex = 0; // General, Account, Services
  final List<String> _tabs = ['FAQ', 'Contact Us'];
  final List<String> _categories = ['General', 'Account', 'Services'];
  final TextEditingController _searchController = TextEditingController();

  // Sample FAQ data (you can replace this with actual data)
  final List<Map<String, String>> _faqs = [
    {'question': 'How to use Flousi?', 'answer': 'Answer to how to use Flousi.'},
    {'question': 'How much does it cost to use Flousi?', 'answer': 'Answer to cost.'},
    {'question': 'How to contact support?', 'answer': 'Answer to contact support.'},
    {'question': 'How can I reset my password if I forget it?', 'answer': 'Answer to reset password.'},
    {'question': 'Are there any privacy or data security measures in place?', 'answer': 'Answer to privacy.'},
    {'question': 'Can I customize settings within the application?', 'answer': 'Answer to customize settings.'},
    {'question': 'How can I delete my account?', 'answer': 'Answer to delete account.'},
    {'question': 'How do I access my expense history?', 'answer': 'Answer to expense history.'},
    {'question': 'Can I use the app offline?', 'answer': 'Answer to offline use.'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: SafeArea(
        bottom: false, // Allow content to extend under bottom nav
        child: Column(
          children: [
            const CustomHeader(title: 'How Can We Help You?'),
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        // FAQ/Contact Us Selector
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.01),
                          decoration: BoxDecoration(
                            color: const Color(0xFF202422),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(_tabs.length, (index) {
                              final isSelected = _selectedTabIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                    vertical: screenWidth * 0.02,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    _tabs[index],
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFF202422) : Colors.white,
                                      fontSize: screenWidth * 0.035 > 14 ? 14 : screenWidth * 0.035,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Category Selector (General, Account, Services)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_categories.length, (index) {
                            final isSelected = _selectedCategoryIndex == index;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategoryIndex = index;
                                });
                              },
                              child: Text(
                                _categories[index],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04,
                                  color: isSelected ? const Color(0xFF202422) : Colors.grey,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Search Bar
                        Container(
                          height: screenHeight * 0.06,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1FFF3),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: const Color(0xFF202422)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.015,
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0xFF202422),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // FAQ List (only shown if FAQ tab is selected)
                        if (_selectedTabIndex == 0) ...[
                          ..._faqs.map((faq) {
                            return ExpansionTile(
                              title: Text(
                                faq['question']!,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04,
                                  color: const Color(0xFF202422),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                    vertical: screenHeight * 0.01,
                                  ),
                                  child: Text(
                                    faq['answer']!,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: screenWidth * 0.035 > 14 ? 14 : screenWidth * 0.035,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                        // Placeholder for Contact Us tab
                        if (_selectedTabIndex == 1) ...[
                          const Center(
                            child: Text(
                              'Contact Us feature coming soon!',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Color(0xFF202422),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: screenHeight * 0.1 + bottomPadding + 20), // Space for bottom nav
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
  }
}