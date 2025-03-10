import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double goalAmount;

  const ProgressBar({
    Key? key,
    required this.progress,
    required this.goalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 27,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(13.5),
          ),
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * progress,
                padding: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * (1 - progress),
            height: 27,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '\$$goalAmount',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: Color(0xFF202422),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
