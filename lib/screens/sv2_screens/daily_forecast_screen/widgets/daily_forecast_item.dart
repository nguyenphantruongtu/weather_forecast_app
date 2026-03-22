import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/data/models/forecast_model.dart';
import 'package:final_project/utils/weather_icon_mapper.dart';

class DailyForecastItem extends StatelessWidget {
  final ForecastModel forecast;
  final int dayNumber;

  const DailyForecastItem({
    super.key,
    required this.forecast,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(forecast.dt);
    final dayName = DateFormat('EEE').format(dateTime);
    final dayDate = DateFormat('MMM d').format(dateTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Day number and date
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  Text(
                    'Day $dayNumber',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    dayDate,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Weather emoji
            Text(
              WeatherIconMapper.getWeatherEmoji(forecast.description),
              style: const TextStyle(fontSize: 28),
            ),

            const SizedBox(width: 12),

            // Temperature and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    forecast.description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'H: ${forecast.tempMax.toStringAsFixed(1)}° L: ${forecast.tempMin.toStringAsFixed(1)}°',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.opacity,
                        size: 14,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${forecast.humidity}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.air, size: 14, color: Colors.blue.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${forecast.windSpeed.toStringAsFixed(1)} m/s',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
