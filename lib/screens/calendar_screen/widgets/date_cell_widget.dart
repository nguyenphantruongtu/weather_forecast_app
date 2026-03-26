import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/weather_day_model.dart';

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
    if (weather == null) {
      return Center(
        child: Text(
          '${date.day}',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    final w = weather!;
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF007AFF)
            : isToday
            ? const Color(0xFF007AFF).withOpacity(0.1)
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
                  ? Colors.white
                  : isToday
                  ? const Color(0xFF007AFF)
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(w.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            '${w.tempMax.round()}°/${w.tempMin.round()}°',
            style: GoogleFonts.inter(
              fontSize: 9,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
