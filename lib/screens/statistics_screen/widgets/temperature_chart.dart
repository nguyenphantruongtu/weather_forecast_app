import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/models/statistics_model.dart';
import '../../../utils/date_formatter.dart';

class TemperatureChart extends StatelessWidget {
  const TemperatureChart({super.key, required this.stats});

  final WeatherStatistics stats;

  @override
  Widget build(BuildContext context) {
    final trend = stats.tempTrend;
    if (trend.isEmpty) {
      return const SizedBox.shrink();
    }

    var maxY = trend
            .map((e) => [e.maxTemp, e.avgTemp, e.minTemp])
            .expand((e) => e)
            .reduce((a, b) => a > b ? a : b) +
        2;
    var minY = trend
            .map((e) => [e.maxTemp, e.avgTemp, e.minTemp])
            .expand((e) => e)
            .reduce((a, b) => a < b ? a : b) -
        2;
    if ((maxY - minY).abs() < 0.01) {
      minY -= 2;
      maxY += 2;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                'Temperature Trends',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                AppDateFormatter.monthYear(DateTime.now()),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) > 0 ? (maxY - minY) / 4 : 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}°',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: trend.length <= 1
                          ? 1
                          : (trend.length / 4).ceilToDouble().clamp(1, 99),
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= trend.length) {
                          return const SizedBox.shrink();
                        }
                        final date = trend[i].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM d').format(date),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
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
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots(trend, 'max'),
                    isCurved: true,
                    color: const Color(0xFFFF3B30),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFFF3B30).withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: _spots(trend, 'avg'),
                    isCurved: true,
                    color: const Color(0xFFFFCC00),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFFFCC00).withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: _spots(trend, 'min'),
                    isCurved: true,
                    color: const Color(0xFF007AFF),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF007AFF).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                label: 'Average',
                value: '${stats.avgTemp.round()}°C',
                color: const Color(0xFFFFCC00),
              ),
              _buildStatColumn(
                label: 'Highest',
                value: '${stats.maxTemp.round()}°C',
                sublabel: AppDateFormatter.shortMonthDay(stats.maxTempDate),
                color: const Color(0xFFFF3B30),
              ),
              _buildStatColumn(
                label: 'Lowest',
                value: '${stats.minTemp.round()}°C',
                sublabel: AppDateFormatter.shortMonthDay(stats.minTempDate),
                color: const Color(0xFF007AFF),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<FlSpot> _spots(List<TempDataPoint> data, String type) {
    return data.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final point = entry.value;
      double value;
      switch (type) {
        case 'max':
          value = point.maxTemp;
          break;
        case 'avg':
          value = point.avgTemp;
          break;
        case 'min':
          value = point.minTemp;
          break;
        default:
          value = point.avgTemp;
      }
      return FlSpot(index, value);
    }).toList();
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    String? sublabel,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (sublabel != null) ...[
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }
}
