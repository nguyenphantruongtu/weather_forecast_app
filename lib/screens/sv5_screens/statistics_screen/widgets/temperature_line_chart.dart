import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/chart_data_model.dart';
import '../utils/chart_data_processor.dart';

class TemperatureLineChart extends StatelessWidget {
  const TemperatureLineChart({super.key, required this.points});

  final List<TemperaturePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(
        child: Text('No trend data', style: TextStyle(color: Colors.white70)),
      );
    }
    final minY = ChartDataProcessor.minTemperatureValue(points);
    final maxY = ChartDataProcessor.maxTemperatureValue(points);
    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.white12, strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          _line(points, (e) => e.max, const Color(0xFFFF6B6B)),
          _line(points, (e) => e.avg, const Color(0xFFFFD93D)),
          _line(points, (e) => e.min, const Color(0xFF4FACFE)),
        ],
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  LineChartBarData _line(
    List<TemperaturePoint> points,
    double Function(TemperaturePoint) extractor,
    Color color,
  ) {
    return LineChartBarData(
      spots: points.map((e) => FlSpot(e.x, extractor(e))).toList(),
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.25), Colors.transparent],
        ),
      ),
    );
  }
}
