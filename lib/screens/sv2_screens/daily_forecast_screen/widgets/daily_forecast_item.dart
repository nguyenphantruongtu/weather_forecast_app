import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/data/models/forecast_model.dart';
import 'package:final_project/data/models/settings_model.dart';
import 'package:final_project/utils/app_strings.dart';
import 'package:final_project/utils/unit_converter.dart';
import 'package:final_project/utils/weather_icon_mapper.dart';

class DailyForecastItem extends StatelessWidget {
  final ForecastModel forecast;
  final int dayNumber;
  final TemperatureUnit temperatureUnit;
  final WindSpeedUnit windSpeedUnit;
  final String languageCode;

  const DailyForecastItem({
    super.key,
    required this.forecast,
    required this.dayNumber,
    required this.temperatureUnit,
    required this.windSpeedUnit,
    required this.languageCode,
  });

  double _displayTemperature(double celsiusValue) {
    if (temperatureUnit == TemperatureUnit.fahrenheit) {
      return UnitConverter.celsiusToFahrenheit(celsiusValue);
    }
    return celsiusValue;
  }

  String _windLabel(double kmhValue) {
    if (windSpeedUnit == WindSpeedUnit.mph) {
      return '${(kmhValue * 0.621371).toStringAsFixed(1)} mph';
    }
    return '${kmhValue.toStringAsFixed(1)} km/h';
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(forecast.dt);
    final dayName = DateFormat('EEE').format(dateTime);
    final dayDate = DateFormat('MMM d').format(dateTime);
    final highTemp = _displayTemperature(forecast.tempMax);
    final lowTemp = _displayTemperature(forecast.tempMin);

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
                    '${AppStrings.tr(languageCode, en: 'Day', vi: 'Ngay')} $dayNumber',
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
                    '${AppStrings.tr(languageCode, en: 'H', vi: 'C')}: ${highTemp.toStringAsFixed(1)}° ${AppStrings.tr(languageCode, en: 'L', vi: 'T')}: ${lowTemp.toStringAsFixed(1)}°',
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
                        _windLabel(forecast.windSpeed),
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
