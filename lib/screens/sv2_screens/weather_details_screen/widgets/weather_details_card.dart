import 'package:flutter/material.dart';
import 'package:final_project/data/models/weather_model.dart';
import 'package:final_project/data/models/settings_model.dart';
import 'package:intl/intl.dart';
import 'package:final_project/utils/app_strings.dart';
import 'package:final_project/utils/unit_converter.dart';

class WeatherDetailsCard extends StatelessWidget {
  final WeatherModel weather;
  final TemperatureUnit temperatureUnit;
  final TimeFormat timeFormat;
  final String languageCode;

  const WeatherDetailsCard({
    super.key,
    required this.weather,
    required this.temperatureUnit,
    required this.timeFormat,
    required this.languageCode,
  });

  double _displayTemperature(double celsiusValue) {
    if (temperatureUnit == TemperatureUnit.fahrenheit) {
      return UnitConverter.celsiusToFahrenheit(celsiusValue);
    }
    return celsiusValue;
  }

  String _datePattern() {
    return timeFormat == TimeFormat.h24 ? 'EEEE, MMM d, y • HH:mm' : 'EEEE, MMM d, y • h:mm a';
  }

  @override
  Widget build(BuildContext context) {
    final displayTemp = _displayTemperature(weather.temperature);
    final displayFeelsLike = _displayTemperature(weather.feelsLike);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.location,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat(_datePattern()).format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${displayTemp.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                weather.description,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                '${AppStrings.tr(languageCode, en: 'Feels like', vi: 'Cam giac nhu')} ${displayFeelsLike.toStringAsFixed(1)}°',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
