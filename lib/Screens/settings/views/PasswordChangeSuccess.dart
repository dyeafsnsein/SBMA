import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared_components/SuccessAnimation.dart';

class PasswordChangeSuccess extends StatelessWidget {
  const PasswordChangeSuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: Center(
        child: SuccessAnimation(
          successMessage: 'Password Has Been\nChanged Successfully',
          onAnimationComplete: () {
            context.go('/profile/settings'); // Goes back to security page
          },
        ),
      ),
    );
  }
}