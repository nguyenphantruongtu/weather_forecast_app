import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/weather_day_model.dart';
import '../utils/temperature_gradient.dart';
import 'animated_weather_icon.dart';

class DateCell extends StatelessWidget {
  const DateCell({
    super.key,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isOutside,
    required this.weather,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;
  final WeatherDayModel? weather;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasData = weather != null;
    final gradient = hasData
        ? TemperatureGradient.fromTemp(weather!.temp)
        : null;
    return Semantics(
      label: 'Weather day ${day.day}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.04 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.all(1),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: BoxDecoration(
              gradient: isOutside
                  ? null
                  : (gradient ??
                        LinearGradient(
                          colors: [
                            Colors.white10,
                            Colors.white.withValues(alpha: 0.04),
                          ],
                        )),
              color: isOutside ? Colors.transparent : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isToday
                    ? const Color(0xFF7FC8FF)
                    : isSelected
                    ? Colors.white
                    : Colors.white24,
                width: isToday || isSelected ? 1.4 : 0.9,
              ),
              boxShadow: isToday
                  ? const [
                      BoxShadow(
                        color: Color(0x553DC1FF),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: GoogleFonts.inter(
                      color: isOutside ? Colors.white38 : Colors.white,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                  if (hasData && !isOutside) ...[
                    const SizedBox(height: 1),
                    AnimatedWeatherIcon(
                      assetPath: weather!.iconAssetPath,
                      size: 14,
                    ),
                    Text(
                      '${weather!.tempMax.round()}°',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 9),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
