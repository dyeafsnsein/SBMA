import 'package:flutter/material.dart';
import 'Home.dart';
class SecurityFingerprintWidget extends StatelessWidget {
  const SecurityFingerprintWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: SafeArea(
        child: Column(
          children: [
            // Dark grey top section
            Expanded(
              flex: 16,
              child: Container(
                color: const Color(0xFF202422),
                child: const Center(
                  child: Text(
                    'Security Fingerprint',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
            // White rectangle with rounded top corners
            Expanded(
              flex: 65,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Fingerprint Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF202422),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.fingerprint,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Use Fingerprint Text
                      const Text(
                        'Use Fingerprint To Access',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF202422),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Description Text
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF202422),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Use Touch ID Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                             Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>  Home()),
                                      );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF202422),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Use Touch ID',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Or use pin code Text
                      const Text(
                        '¿Or prefer use pin code?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF202422),
                          fontFamily: 'Poppins',
                        ),
                      ),
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
