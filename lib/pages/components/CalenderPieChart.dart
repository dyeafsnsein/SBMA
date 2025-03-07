import 'package:flutter/material.dart';
import 'dart:math';

class CategoryPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const CategoryPieChart({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Semi-circle pie chart
        SizedBox(
          height: 180,
          child: CustomPaint(
            size: const Size(double.infinity, 180),
            painter: SemiCirclePieChartPainter(categories),
          ),
        ),
        
        // Legend
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: categories.map((category) {
            // Skip categories without names
            if (!category.containsKey('name') || category['name'] == null) {
              return const SizedBox.shrink();
            }
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: category['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF202422),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SemiCirclePieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;

  SemiCirclePieChartPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width * 0.4;
    
    double startAngle = pi; // Start from the left (180 degrees in radians)
    
    for (var category in categories) {
      final paint = Paint()
        ..color = category['color']
        ..style = PaintingStyle.fill;
      
      final sweepAngle = category['percentage'] / 100 * pi; // Only sweep through 180 degrees (pi radians)
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      // Draw percentage text
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${category['percentage']}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
