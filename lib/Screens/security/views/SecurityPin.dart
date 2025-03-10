import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../password/views/NewPassword.dart';
import 'SecurityFingerprint.dart';

class SecurityPinWidget extends StatefulWidget {
  const SecurityPinWidget({Key? key}) : super(key: key);

  @override
  _SecurityPinWidgetState createState() => _SecurityPinWidgetState();
}

class _SecurityPinWidgetState extends State<SecurityPinWidget> {
  final int pinLength = 6;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
                    'Security Pin',
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
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Enter Security Pin Text
                        const Text(
                          'Enter Security Pin',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF202422),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Pin Input
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(_focusNode);
                          },
                          child: _buildPinInput(),
                        ),
                        const SizedBox(height: 50),
                        // Action Buttons
                        SizedBox(
                          width: 169,
                          height: 36,
                          child: ElevatedButton(
                              onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const NewPasswordWidget()),
                                      );
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF202422),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Accept',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 19),
                        SizedBox(
                          width: 169,
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () { Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const SecurityFingerprintWidget()),
                                      );},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Send again',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF202422),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Social Login
                        const Text(
                          'or sign up with',
                          style: TextStyle(
                            color: Color(0xFF3299FF),
                            fontFamily: 'League Spartan',
                            fontWeight: FontWeight.w300,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Image.network(
                                'https://dashboard.codeparrot.ai/api/image/Z7u4i1CHtJJZ6wGn/facebook.png',
                                width: 32.71,
                                height: 32.65,
                              ),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Image.network(
                                'https://dashboard.codeparrot.ai/api/image/Z7u4i1CHtJJZ6wGn/google.png',
                                width: 32.71,
                                height: 32.71,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Don't have an account? Sign Up",
                            style: TextStyle(
                              color: Color(0xFF202422),
                              fontFamily: 'League Spartan',
                              fontWeight: FontWeight.w300,
                              fontSize: 13,
                            ),
                          ),
                        ),
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

  Widget _buildPinInput() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pinLength, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.5),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x8C808080),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    _controller.text.length > index ? _controller.text[index] : '-',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0x8C808080),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        // Invisible TextField to capture input
        Opacity(
          opacity: 0.0,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: pinLength,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
