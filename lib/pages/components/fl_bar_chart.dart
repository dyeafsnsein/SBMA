import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FlBarChart extends StatefulWidget {
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
  State<FlBarChart> createState() => _FlBarChartState();
}

class _FlBarChartState extends State<FlBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isTransitioning = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isTransitioning = false;
        });
      }
    });
  }
  
  @override
  void didUpdateWidget(FlBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if data has changed
    if (oldWidget.labels != widget.labels) {
      setState(() {
        _isTransitioning = true;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the maximum value to set appropriate maxY
    double maxValue = 0;
    for (int i = 0; i < widget.expenses.length; i++) {
      maxValue = maxValue > widget.expenses[i] ? maxValue : widget.expenses[i];
      maxValue = maxValue > widget.income[i] ? maxValue : widget.income[i];
    }
    
    // Add 20% padding to the max value and ensure a minimum value
    maxValue = maxValue * 1.2;
    maxValue = maxValue < 10 ? 10 : maxValue; // Ensure minimum maxY of 10
    
    // Determine the appropriate interval based on the max value
    double interval = 5;
    if (maxValue > 1000) interval = 500;
    else if (maxValue > 100) interval = 200;
    else if (maxValue > 50) interval = 20;
    else if (maxValue > 20) interval = 10;
    else interval = 5;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF202422),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              const Text(
                'Income & Expenses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildIconButton(
                    icon: 'lib/pages/assets/Search.png',
                    onTap: () {
                      // Implement search functionality
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: 'lib/pages/assets/Calendar.png',
                    onTap: () {
                      // Implement calendar functionality
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: AnimatedOpacity(
              opacity: _isTransitioning ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue,
                  minY: 0,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String type = rodIndex == 0 ? 'Expense' : 'Income';
                        double value = rod.toY;
                        String displayValue = value >= 1000 ? '${(value/1000).toStringAsFixed(1)}k' : value.toStringAsFixed(0);
                        return BarTooltipItem(
                          '$type: $displayValue',
                          const TextStyle(color: Colors.white),
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
                          if (index >= 0 && index < widget.labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                widget.labels[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 22,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: const SizedBox(), // Remove axis name
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          String displayValue = value >= 1000 ? '${(value/1000).toStringAsFixed(0)}k' : value.toStringAsFixed(0);
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              displayValue,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
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
                      color: Colors.white.withOpacity(0.1),
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
                  barGroups: widget.expenses.asMap().entries.map((entry) {
                    int index = entry.key;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: widget.expenses[index],
                          gradient: const LinearGradient(
                            colors: [Colors.redAccent, Colors.red],
                          ),
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxValue,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        BarChartRodData(
                          toY: widget.income[index],
                          gradient: const LinearGradient(
                            colors: [Colors.greenAccent, Colors.green],
                          ),
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxValue,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ],
                      barsSpace: 4,
                    );
                  }).toList(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 500),
                swapAnimationCurve: Curves.easeInOut,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: Colors.red,
                label: 'Expenses',
              ),
              const SizedBox(width: 20),
              _buildLegendItem(
                color: Colors.green,
                label: 'Income',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required String icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            icon,
            width: 16,
            height: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
