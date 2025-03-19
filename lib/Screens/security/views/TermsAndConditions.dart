import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared_components/custom_header.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({Key? key}) : super(key: key);

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
            const CustomHeader(title: 'Terms And Conditions'),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Est Fugiat Assumenda Aut Reprehenderit',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.05 > 24 ? 24 : screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF202422),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Lorem ipsum dolor sit amet. Et odio officia aut voluptate internos est omnis vitae ut architecto sunt non tenetur fuga ut provident vero. Quo aspernatur facere et consectetur ipsum et facere corrupti est asperiores facere. Est fugiat assumenda aut reprehenderit voluptatem sed.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.035 > 16 ? 16 : screenWidth * 0.035,
                          color: const Color(0xFF202422),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        '1. Ea voluptates omnis aut sequi sequi.\n2. Est dolore quae in aliquid ducimus et autem repellendus.\n3. Aut ipsum Quis qui porro quasi aut minus placeat!\n4. Sit consequatur neque ab vitae facere.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.035 > 16 ? 16 : screenWidth * 0.035,
                          color: const Color(0xFF202422),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Aut quidem accusantium nam alias autem eum officiis placeat et omnis autem id officiis perspiciatis qui corrupti officia eum aliquam provident. Eum voluptas error et optio dolorum cum molestiae nobis et odit molestiae quo magnam impedit sed fugiat nihil non nihil vitae.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.035 > 16 ? 16 : screenWidth * 0.035,
                          color: const Color(0xFF202422),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        '• Aut fuga sequi eum voluptatibus provident.\n• Eos consequuntur voluptas vel amet eaque aut dignissimos velit.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.035 > 16 ? 16 : screenWidth * 0.035,
                          color: const Color(0xFF202422),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Vel exercitationem quam vel eligendi rerum At harum obcaecati et nostrum beatae? Ea accusantium dolores qui rerum aliquam est perferendis mollitia et ipsum ipsa qui enim autem At corporis sunt. Aut odit quisquam est reprehenderit itaque aut accusantium dolor qui neque repellat.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.035 > 16 ? 16 : screenWidth * 0.035,
                          color: const Color(0xFF202422),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Read the terms and conditions in more detail at www.finwiseapp.de',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.035 > 16 ? 16 : screenWidth * 0.035,
                          color: const Color(0xFF202422),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/profile/security-edit');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF202422),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.1 > 50 ? 50 : screenWidth * 0.1,
                              vertical: screenHeight * 0.02 > 20 ? 20 : screenHeight * 0.02,
                            ),
                            minimumSize: Size(screenWidth * 0.5, 50),
                          ),
                          child: Text(
                            'Accept',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.04 > 18 ? 18 : screenWidth * 0.04,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.1 + bottomPadding + 20), // Space for bottom nav
                    ],
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