import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:dukalipa_app/core/theme/dukalipa_colors.dart';

class SimpleSalesChart extends StatefulWidget {
  final double width;
  final double height;

  const SimpleSalesChart({
    Key? key,
    this.width = double.infinity,
    this.height = 200,
  }) : super(key: key);

  @override
  State<SimpleSalesChart> createState() => _SimpleSalesChartState();
}

class _SimpleSalesChartState extends State<SimpleSalesChart> {
  int touchedIndex = -1;
  
  // Sample data - in a real app, this would come from a repository
  final List<Map<String, dynamic>> salesData = [
    {'day': 'Mon', 'sales': 42000},
    {'day': 'Tue', 'sales': 55000},
    {'day': 'Wed', 'sales': 48000},
    {'day': 'Thu', 'sales': 61000},
    {'day': 'Fri', 'sales': 78000},
    {'day': 'Sat', 'sales': 52000},
    {'day': 'Sun', 'sales': 40000},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.grey.shade800,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${salesData[groupIndex]['day']}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'TSh ${NumberFormat('#,###').format(salesData[groupIndex]['sales'])}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              // Using a safe setState approach to avoid calling during build
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                if (touchedIndex != -1) {
                  // Only setState if needed
                  Future.microtask(() {
                    if (mounted) {
                      setState(() {
                        touchedIndex = -1;
                      });
                    }
                  });
                }
                return;
              }
              
              final touchedBarIndex = barTouchResponse.spot!.touchedBarGroupIndex;
              if (touchedIndex != touchedBarIndex) {
                // Only setState if value changed, and use microtask to avoid during build
                Future.microtask(() {
                  if (mounted) {
                    setState(() {
                      touchedIndex = touchedBarIndex;
                    });
                  }
                });
              }
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      salesData[value.toInt()]['day'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String text = '';
                  if (value == 0) {
                    text = '0';
                  } else if (value == 40000) {
                    text = '40K';
                  } else if (value == 80000) {
                    text = '80K';
                  }
                  
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: salesData.asMap().entries.map((entry) {
            final int index = entry.key;
            final Map<String, dynamic> data = entry.value;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data['sales'].toDouble(),
                  color: touchedIndex == index 
                      ? AirbnbColors.primary 
                      : AirbnbColors.primary.withOpacity(0.6),
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 80000,
                    color: Colors.grey.withOpacity(0.1),
                  )
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          maxY: 80000,
        ),
      ),
    );
  }
}
