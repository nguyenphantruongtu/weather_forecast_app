import 'package:flutter/material.dart';
import 'package:final_project/data/models/weather_model.dart';
import 'package:final_project/data/models/settings_model.dart';
import 'package:final_project/utils/app_strings.dart';
import 'package:final_project/utils/unit_converter.dart';

class AtmosphericMetricsGrid extends StatelessWidget {
  final WeatherModel weather;
  final TemperatureUnit temperatureUnit;
  final String languageCode;

  const AtmosphericMetricsGrid({
    super.key,
    required this.weather,
    required this.temperatureUnit,
    required this.languageCode,
  });

  double _displayTemperature(double celsiusValue) {
    if (temperatureUnit == TemperatureUnit.fahrenheit) {
      return UnitConverter.celsiusToFahrenheit(celsiusValue);
    }
    return celsiusValue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.tr(languageCode, en: 'Atmospheric Conditions', vi: 'Dieu kien khi quyen'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _MetricCard(
                  icon: Icons.compress,
                  label: AppStrings.tr(languageCode, en: 'Pressure', vi: 'Ap suat'),
                  value: '${weather.pressure} hPa',
                  badge: AppStrings.tr(languageCode, en: 'Normal', vi: 'Binh thuong'),
                ),
                _MetricCard(
                  icon: Icons.visibility,
                  label: AppStrings.tr(languageCode, en: 'Visibility', vi: 'Tam nhin'),
                  value: '${weather.visibility.toStringAsFixed(1)} km',
                  badge: AppStrings.tr(languageCode, en: 'Excellent', vi: 'Rat tot'),
                ),
                _MetricCard(
                  icon: Icons.opacity,
                  label: AppStrings.tr(languageCode, en: 'Dew Point', vi: 'Diem suong'),
                  value: '${_displayTemperature(weather.dewPoint).toStringAsFixed(1)}°',
                  badge: AppStrings.tr(languageCode, en: 'Comfortable', vi: 'De chiu'),
                ),
                _MetricCard(
                  icon: Icons.cloud_queue,
                  label: AppStrings.tr(languageCode, en: 'Humidity', vi: 'Do am'),
                  value: '${weather.humidity}%',
                  badge: weather.humidity > 70
                      ? AppStrings.tr(languageCode, en: 'High', vi: 'Cao')
                      : AppStrings.tr(languageCode, en: 'Normal', vi: 'Binh thuong'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String badge;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.blue.shade600, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
