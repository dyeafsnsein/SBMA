import 'package:flutter/material.dart';

class SuccessAnimation extends StatefulWidget {
  final String successMessage;
  final VoidCallback onAnimationComplete;

  const SuccessAnimation({
    Key? key,
    required this.successMessage,
    required this.onAnimationComplete,
  }) : super(key: key);

  @override
  _SuccessAnimationState createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation> with TickerProviderStateMixin {
  late AnimationController _dotsController;
  late AnimationController _checkmarkController;
  late Animation<double> _dotsAnimation;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _textOpacityAnimation;
  bool _showCheckmark = false;

  @override
  void initState() {
    super.initState();
    
    // Dots animation controller
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    // Checkmark animation controller
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _dotsAnimation = Tween<double>(begin: 0, end: 1).animate(_dotsController);
    
    _checkmarkAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    ));
    
    _textOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.easeIn,
    ));

    // Listen to dots animation completion
    _dotsController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showCheckmark = true);
        _checkmarkController.forward();
      }
    });

    // Listen to checkmark animation completion and call the callback
    _checkmarkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            widget.onAnimationComplete();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: screenWidth * 0.3,
          height: screenWidth * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFF1FFF3), width: 4),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: _showCheckmark
                ? ScaleTransition(
                    scale: _checkmarkAnimation,
                    child: Icon(
                      Icons.check,
                      size: screenWidth * 0.15,
                      color: const Color(0xFFF1FFF3),
                    ),
                  )
                : AnimatedBuilder(
                    animation: _dotsAnimation,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDot(_dotsAnimation.value > 0.33 ? 1 : 0),
                          SizedBox(width: screenWidth * 0.02),
                          _buildDot(_dotsAnimation.value > 0.66 ? 1 : 0),
                          SizedBox(width: screenWidth * 0.02),
                          _buildDot(_dotsAnimation.value > 0.99 ? 1 : 0),
                        ],
                      );
                    },
                  ),
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        FadeTransition(
          opacity: _textOpacityAnimation,
          child: Text(
            widget.successMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: screenWidth * 0.05,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(double opacity) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: const Color(0xFFF1FFF3),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}