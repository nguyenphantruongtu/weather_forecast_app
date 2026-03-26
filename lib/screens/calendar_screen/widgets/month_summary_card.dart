import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/calendar_provider.dart';
import '../../../providers/widget_config_provider.dart';
import 'weather_bar_chart.dart';

class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final summary = provider.getMonthSummary();
    final widgetTheme = context.watch<WidgetConfigProvider>().selectedTheme;
    final isDark = widgetTheme.name == 'Dark Mode';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Month Summary',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  label: 'Avg Temp',
                  value: '${summary.avgTemp.round()}°C',
                  icon: Icons.thermostat,
                  color: const Color(0xFFFF9500),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  label: 'Total Rainfall',
                  value: '${summary.totalRainfall.round()} mm',
                  icon: Icons.water_drop,
                  color: isDark ? Colors.white : widgetTheme.color,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDaysStat(
                  icon: '☀️',
                  label: 'Sunny Days',
                  count: summary.sunnyDays,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildDaysStat(
                  icon: '🌧️',
                  label: 'Rainy Days',
                  count: summary.rainyDays,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: WeatherBarChart(dailyTemps: summary.dailyAvgTemps),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isDark = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDaysStat({
    required String icon,
    required String label,
    required int count,
    bool isDark = false,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
            ),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
