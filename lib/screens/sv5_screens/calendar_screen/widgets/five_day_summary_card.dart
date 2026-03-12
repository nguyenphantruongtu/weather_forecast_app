import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/calendar_weather_model.dart';
import '../models/weather_day_model.dart';

/// Thẻ tóm tắt dự báo 5 ngày (giống Month Summary trong hình).
class FiveDaySummaryCard extends StatelessWidget {
  const FiveDaySummaryCard({super.key, required this.summary});

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
            'Dự báo 5 ngày',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metricChip(
                  Icons.thermostat,
                  'Nhiệt độ TB',
                  '${summary.averageTemp.toStringAsFixed(0)}°C',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricChip(
                  Icons.water_drop_outlined,
                  'Ngày mưa',
                  '${summary.rainyDays}',
                ),
              ),
            ],
          ),
          if (summary.hottestDay != null || summary.coldestDay != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (summary.hottestDay != null)
                  Expanded(
                    child: Text(
                      'Cao nhất ${summary.hottestDay!.tempMax.toStringAsFixed(0)}°',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (summary.coldestDay != null)
                  Expanded(
                    child: Text(
                      'Thấp nhất ${summary.coldestDay!.tempMin.toStringAsFixed(0)}°',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
