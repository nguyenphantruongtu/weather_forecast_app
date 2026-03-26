import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/statistics_model.dart';

class ComparisonIndicator extends StatelessWidget {
  const ComparisonIndicator({super.key, required this.stats});

  final WeatherStatistics stats;

  @override
  Widget build(BuildContext context) {
    if (stats.comparisonDiff == 0) {
      return const SizedBox.shrink();
    }

    final label = switch (stats.period) {
      'Week' => 'vs previous week',
      'Month' => 'vs previous month',
      'Year' => 'vs previous year',
      _ => 'vs previous range',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            stats.comparisonUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 18,
            color: stats.comparisonUp
                ? const Color(0xFF34C759)
                : const Color(0xFFFF3B30),
          ),
          const SizedBox(width: 6),
          Text(
            '${stats.comparisonDiff.toStringAsFixed(1)}° avg $label',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
