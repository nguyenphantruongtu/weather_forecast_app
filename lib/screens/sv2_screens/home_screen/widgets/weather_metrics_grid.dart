import 'package:flutter/material.dart';
import '../../../../data/models/weather_model.dart';
import '../../../../data/models/settings_model.dart';
import '../../../../utils/unit_converter.dart';

class WeatherMetricsGrid extends StatelessWidget {
  final WeatherModel weather;
  final TemperatureUnit temperatureUnit;
  final WindSpeedUnit windSpeedUnit;

  const WeatherMetricsGrid({
    super.key,
    required this.weather,
    required this.temperatureUnit,
    required this.windSpeedUnit,
  });

  double _displayTemperature(double celsiusValue) {
    if (temperatureUnit == TemperatureUnit.fahrenheit) {
      return UnitConverter.celsiusToFahrenheit(celsiusValue);
    }
    return celsiusValue;
  }

  String _windLabel() {
    if (windSpeedUnit == WindSpeedUnit.mph) {
      final mph = weather.windSpeed * 0.621371;
      return '${mph.toStringAsFixed(1)} mph';
    }
    return '${weather.windSpeed.toStringAsFixed(1)} km/h';
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _MetricCard(
          icon: Icons.opacity,
          label: 'Humidity',
          value: '${weather.humidity}%',
          color: Colors.blue,
        ),
        _MetricCard(
          icon: Icons.air,
          label: 'Wind',
          value: _windLabel(),
          color: Colors.cyan,
        ),
        _MetricCard(
          icon: Icons.speed,
          label: 'Pressure',
          value: '${weather.pressure} hPa',
          color: Colors.indigo,
        ),
        _MetricCard(
          icon: Icons.visibility,
          label: 'Visibility',
          value: '${weather.visibility.toStringAsFixed(1)} km',
          color: Colors.orange,
        ),
        _MetricCard(
          icon: Icons.wb_sunny,
          label: 'UV Index',
          value: weather.uvIndex.toStringAsFixed(1),
          color: Colors.amber,
        ),
        _MetricCard(
          icon: Icons.thermostat,
          label: 'Dew Point',
          value: '${_displayTemperature(weather.dewPoint).toStringAsFixed(0)}°',
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
