import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/models/weather_day_model.dart';
import '../../../providers/widget_config_provider.dart';

class DateCellWidget extends StatelessWidget {
  const DateCellWidget({
    super.key,
    required this.date,
    this.weather,
    this.isToday = false,
    this.isSelected = false,
  });

  final DateTime date;
  final WeatherDay? weather;
  final bool isToday;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final widgetTheme = context.watch<WidgetConfigProvider>().selectedTheme;
    final isDark = widgetTheme.name == 'Dark Mode';
    final accentColor = isDark ? Colors.white : widgetTheme.color;

    if (weather == null) {
      return Center(
        child: Text(
          '${date.day}',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
        ),
      );
    }

    final w = weather!;
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? accentColor
            : isToday
            ? accentColor.withOpacity(0.15)
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.black87 : Colors.white)
                  : isToday
                  ? accentColor
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 2),
          Text(w.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            '${w.tempMax.round()}°/${w.tempMin.round()}°',
            style: GoogleFonts.inter(
              fontSize: 9,
              color: isSelected
                  ? (isDark ? Colors.black54 : Colors.white70)
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
