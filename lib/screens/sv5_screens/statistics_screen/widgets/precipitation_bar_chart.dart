import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/chart_data_model.dart';
import '../utils/chart_data_processor.dart';

class PrecipitationBarChart extends StatelessWidget {
  const PrecipitationBarChart({super.key, required this.points});

  final List<PrecipitationPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(
        child: Text(
          'No precipitation data',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    final maxY = ChartDataProcessor.maxPrecipitationValue(points);
    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        barGroups: points
            .map(
              (e) => BarChartGroupData(
                x: e.x.toInt(),
                barRods: [
                  BarChartRodData(
                    toY: e.amount,
                    width: 8,
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6BCF7F), Color(0xFF43E97B)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
      swapAnimationDuration: const Duration(milliseconds: 300),
      swapAnimationCurve: Curves.easeInOut,
    );
  }
}
