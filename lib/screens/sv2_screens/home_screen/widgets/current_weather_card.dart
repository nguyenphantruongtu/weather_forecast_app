import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/weather_model.dart';
import '../../../../data/models/settings_model.dart';
import '../../../../utils/app_strings.dart';
import '../../../../utils/unit_converter.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final VoidCallback onSettingsTap;
  final TemperatureUnit temperatureUnit;
  final TimeFormat timeFormat;
  final String languageCode;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    required this.onSettingsTap,
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

  String _timePattern() {
    return timeFormat == TimeFormat.h24
        ? 'EEE, MMM d • HH:mm'
        : 'EEE, MMM d • h:mm a';
  }

  String _getWeatherIcon(String description) {
    switch (description.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTemp = _displayTemperature(weather.temperature);
    final displayFeelsLike = _displayTemperature(weather.feelsLike);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat(_timePattern()).format(weather.lastUpdated),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              IconButton(
                onPressed: onSettingsTap,
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${displayTemp.toStringAsFixed(0)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weather.description,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    '${AppStrings.tr(languageCode, en: 'Feels like', vi: 'Cảm giác như')} ${displayFeelsLike.toStringAsFixed(0)}°',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Text(
                _getWeatherIcon(weather.description),
                style: const TextStyle(fontSize: 80),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
