import 'package:flutter/material.dart';

class TargetsSection extends StatelessWidget {
  final List<Map<String, dynamic>> targets;

  const TargetsSection({
    Key? key,
    required this.targets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (targets.isNotEmpty)
          Text(
            'My Targets',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF202422),
            ),
          ),
        if (targets.isNotEmpty) SizedBox(height: screenHeight * 0.02),
        if (targets.isNotEmpty)
          SizedBox(
            height: screenWidth * 0.45, // Ensure enough height for cards
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: targets.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildTargetItem(
                  name: targets[index]['name'],
                  progress: targets[index]['progress'],
                  screenWidth: screenWidth,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTargetItem({
    required String name,
    required double progress,
    required double screenWidth,
  }) {
    return Container(
      width: screenWidth * 0.4,
      height: screenWidth * 0.4,
      margin:
          const EdgeInsets.only(bottom: 8), // Add margin to prevent overflow
      decoration: BoxDecoration(
        color: const Color(0xFF202422),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: screenWidth * 0.25,
                height: screenWidth * 0.25,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withAlpha((0.2 * 255).toInt()),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF00FF94)),
                  strokeWidth: 8,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
