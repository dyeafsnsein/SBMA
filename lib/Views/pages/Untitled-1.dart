import 'package:flutter/material.dart';

class LoginFormComponent extends StatefulWidget {
  final String emailHint;
  final String passwordHint;
  final String loginButtonText;

  const LoginFormComponent({
    Key? key,
    this.emailHint = 'example@example.com',
    this.passwordHint = '●●●●●●●●',
    this.loginButtonText = 'Log In',
  }) : super(key: key);

  @override
  _LoginFormComponentState createState() => _LoginFormComponentState();
}

class _LoginFormComponentState extends State<LoginFormComponent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth > 400 ? 356 : constraints.maxWidth * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Username or email',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202422),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: widget.emailHint,
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF202422).withOpacity(0.45),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Password',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202422),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: widget.passwordHint,
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      letterSpacing: 8.4,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF202422).withOpacity(0.45),
                    ),
                    suffixIcon: IconButton(
                      icon: Image.network(
                        'https://dashboard.codeparrot.ai/api/image/Z7uZpFCHtJJZ6wGS/eye-pass.png',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Handle login logic here
                  },
                  child: Container(
                    width: 207,
                    height: 45,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://dashboard.codeparrot.ai/api/image/Z7uZpFCHtJJZ6wGS/group-54.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.loginButtonText,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFCFCFC),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

