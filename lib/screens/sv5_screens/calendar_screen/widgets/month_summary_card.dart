import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/calendar_weather_model.dart';

class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({super.key, required this.summary});

  final CalendarWeatherSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667eea).withValues(alpha: 0.75),
            const Color(0xFF764ba2).withValues(alpha: 0.75),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Summary',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _line(
            'Average Temperature',
            '${summary.averageTemp.toStringAsFixed(1)}°C',
          ),
          _line('Total Rainy Days', '${summary.rainyDays}'),
          _line(
            'Hottest Day',
            summary.hottestDay == null
                ? '-'
                : '${DateFormat('dd MMM').format(summary.hottestDay!.date)} (${summary.hottestDay!.tempMax.toStringAsFixed(1)}°)',
          ),
          _line(
            'Coldest Day',
            summary.coldestDay == null
                ? '-'
                : '${DateFormat('dd MMM').format(summary.coldestDay!.date)} (${summary.coldestDay!.tempMin.toStringAsFixed(1)}°)',
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
