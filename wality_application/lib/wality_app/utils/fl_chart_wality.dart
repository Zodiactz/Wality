import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FlChartWality extends StatelessWidget {
  const FlChartWality({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: const FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: const Color(0xff37434d),
                                width: 1,
                              ),
                            ),
                            minX: 0,
                            maxX: 7,
                            minY: 0,
                            maxY: 6,
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  const FlSpot(0, 3),
                                  const FlSpot(1, 1),
                                  const FlSpot(2, 4),
                                  const FlSpot(3, 3),
                                  const FlSpot(4, 5),
                                  const FlSpot(5, 2),
                                  const FlSpot(6, 4),
                                ],
                                isCurved: true,
                                color: const Color(0xff23b6e6),
                                barWidth: 5,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
    );
  }
}


                    
                        
            