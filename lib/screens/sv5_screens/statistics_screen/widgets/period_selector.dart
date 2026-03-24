import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/statistics_provider.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final StatisticsPeriod selected;
  final ValueChanged<StatisticsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<StatisticsPeriod, String>>[
      const MapEntry(StatisticsPeriod.week, 'Week'),
      const MapEntry(StatisticsPeriod.month, 'Month'),
      const MapEntry(StatisticsPeriod.threeMonths, '3 Mo'),
      const MapEntry(StatisticsPeriod.year, 'Year'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: Colors.white12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: items.map((entry) {
          final active = entry.key == selected;
          return GestureDetector(
            onTap: () => onChanged(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: active
                    ? const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      )
                    : null,
              ),
              child: Text(
                entry.value,
                style: GoogleFonts.inter(
                  color: active ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          );
        }).toList(),
        ),
      ),
    );
  }
}
