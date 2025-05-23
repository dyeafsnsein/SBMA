import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

class FlBarChart extends StatelessWidget {
  final List<double> expenses;
  final List<double> income;
  final List<String> labels;

  const FlBarChart({
    super.key,
    required this.expenses,
    required this.income,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double maxValue = 0;
    for (int i = 0; i < expenses.length; i++) {
      maxValue = maxValue > expenses[i] ? maxValue : expenses[i];
      maxValue = maxValue > income[i] ? maxValue : income[i];
    }

    maxValue = maxValue * 1.2;
    maxValue = maxValue < 10 ? 10 : maxValue;

    // Aim for approximately 5 labels on the Y-axis
    const desiredLabelCount = 5;
    final interval = (maxValue / (desiredLabelCount - 1)).ceilToDouble();
    final adjustedMaxValue = interval * (desiredLabelCount - 1);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF202422),
        borderRadius: BorderRadius.circular(screenWidth * 0.08),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Income & Expenses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildIconButton(
                    icon: 'lib/assets/Search.png',
                    onTap: () => context.push('/search'),
                    screenWidth: screenWidth,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          SizedBox(
            height: screenHeight * 0.16,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: adjustedMaxValue,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipPadding: EdgeInsets.all(screenWidth * 0.02),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String type = rodIndex == 0 ? 'Expense' : 'Income';
                      double value = rod.toY;
                      String displayValue = value >= 1000
                          ? '${(value / 1000).toStringAsFixed(1)}k'
                          : value.toStringAsFixed(0);
                      return BarTooltipItem(
                        '$type: $displayValue',
                        TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.03,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.01),
                            child: Text(
                              labels[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.025,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: screenHeight * 0.05,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const SizedBox(),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: screenWidth * 0.07,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        if (value > adjustedMaxValue) return const SizedBox();
                        String displayValue = value >= 1000
                            ? '${(value / 1000).toStringAsFixed(0)}k'
                            : value.toStringAsFixed(0);
                        return Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.01),
                          child: Text(
                            displayValue,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: interval,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withAlpha((0.1 * 255).toInt()),
                    strokeWidth: 1,
                  ),
                  checkToShowHorizontalLine: (value) => value != 0,
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
                barGroups: expenses.asMap().entries.map((entry) {
                  int index = entry.key;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: expenses[index],
                        gradient: const LinearGradient(
                          colors: [Colors.redAccent, Colors.red],
                        ),
                        width: screenWidth * 0.02,
                        borderRadius: BorderRadius.circular(2),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: adjustedMaxValue,
                          color: Colors.white.withAlpha((0.1 * 255).toInt()),
                        ),
                      ),
                      BarChartRodData(
                        toY: income[index],
                        gradient: const LinearGradient(
                          colors: [Colors.greenAccent, Colors.green],
                        ),
                        width: screenWidth * 0.02,
                        borderRadius: BorderRadius.circular(2),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: adjustedMaxValue,
                          color: Colors.white.withAlpha((0.1 * 255).toInt()),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required String icon,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.08,
        height: screenWidth * 0.08,
        decoration: BoxDecoration(
          color: const Color(0xFF050505),
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Center(
          child: Image.asset(
            icon,
            width: screenWidth * 0.04,
            height: screenWidth * 0.04,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
