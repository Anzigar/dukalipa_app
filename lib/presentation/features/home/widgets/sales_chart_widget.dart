import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


// NOTE: This widget is currently not actively used in the app.
// SimpleSalesChart is used instead. This file is maintained for reference.
class SalesChartWidget extends StatelessWidget {
  final List<double> dailySales;
  final DateTime startDate;
  
  SalesChartWidget({
    super.key,
    this.dailySales = const [5000, 8000, 7500, 9000, 12000, 15000, 10000, 11000, 9500, 13000, 8000, 20000, 35000, 80000, 50000, 25000],
    DateTime? startDate,
  }) : startDate = startDate ?? DateTime(2023, 1, 1);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sales Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'May\'s spend',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 20000,
                  verticalInterval: 3,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        switch (value.toInt()) {
                          case 0:
                            text = 'TZS 0';
                            break;
                          case 20000:
                            text = '20k';
                            break;
                          case 40000:
                            text = '40k';
                            break;
                          case 60000:
                            text = '60k';
                            break;
                          case 80000:
                            text = '80k';
                            break;
                        }
                        return Text(
                          text,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
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
                        final index = value.toInt();
                        if (index == 1 || index == 4 || index == 7 || index == 10 || index == 13 || index == 16) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              index.toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      dailySales.length,
                      (index) => FlSpot(index.toDouble() + 1, dailySales[index]),
                    ),
                    isCurved: true,
                    barWidth: 2,
                    color: Colors.green,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.8),
                          Colors.green.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        // Only show dots at specific points (10, 13)
                        return spot.x == 10 || spot.x == 13;
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.green,
                        );
                      },
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.shade800,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          'TZS ${touchedSpot.y.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                minX: 1,
                maxX: 16,
                minY: 0,
                maxY: 80000,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
