import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/weather_day_model.dart';
import 'animated_weather_icon.dart';

/// Danh sách dự báo 5 ngày kiểu iOS: mỗi dòng = tên ngày, icon, nhiệt cao/thấp.
class FiveDayForecastList extends StatelessWidget {
  const FiveDayForecastList({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onDaySelected,
  });

  final List<WeatherDayModel> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: Colors.white30),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < days.length; i++) ...[
              _ForecastRow(
                weather: days[i],
                isSelected: DateUtils.isSameDay(days[i].date, selectedDate),
                isToday: DateUtils.isSameDay(days[i].date, DateTime.now()),
                onTap: () => onDaySelected(days[i].date),
              ),
              if (i < days.length - 1)
                Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({
    required this.weather,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final WeatherDayModel weather;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dayLabel = isToday
        ? 'Hôm nay'
        : DateFormat('EEE, d/M').format(weather.date);

    return Material(
      color: isSelected
          ? Colors.white.withValues(alpha: 0.15)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  dayLabel,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: isToday || isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
              AnimatedWeatherIcon(
                assetPath: weather.iconAssetPath,
                size: 28,
              ),
              const Spacer(),
              Text(
                '${weather.tempMax.round()}° / ${weather.tempMin.round()}°',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
