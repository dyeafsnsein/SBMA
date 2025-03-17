import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared_components/SuccessAnimation.dart';

class FingerprintDeleteSuccess extends StatelessWidget {
  const FingerprintDeleteSuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: Center(
        child: SuccessAnimation(
          successMessage: 'The Fingerprint Has\nBeen Successfully Deleted.',
          onAnimationComplete: () {
            context.go('/profile/security-edit'); // Goes back to security page
          },
        ),
      ),
    );
  }
}