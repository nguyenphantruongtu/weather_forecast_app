import 'package:flutter/material.dart';
import 'package:final_project/data/models/weather_model.dart';
import 'package:final_project/data/models/settings_model.dart';
import 'package:final_project/utils/app_strings.dart';

class WindDetailsCard extends StatelessWidget {
  final WeatherModel weather;
  final WindSpeedUnit windSpeedUnit;
  final String languageCode;

  const WindDetailsCard({
    super.key,
    required this.weather,
    required this.windSpeedUnit,
    required this.languageCode,
  });

  String _displayWind(double kmhValue) {
    if (windSpeedUnit == WindSpeedUnit.mph) {
      return (kmhValue * 0.621371).toStringAsFixed(1);
    }
    return kmhValue.toStringAsFixed(1);
  }

  String _unitLabel() {
    if (windSpeedUnit == WindSpeedUnit.mph) return 'mph';
    return 'km/h';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.tr(languageCode, en: 'Wind Details', vi: 'Chi tiet gio'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.cyan.shade400,
                              Colors.blue.shade600,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _displayWind(weather.windSpeed),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _unitLabel(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getWindSpeed(weather.windSpeed),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        label: AppStrings.tr(languageCode, en: 'Speed', vi: 'Toc do'),
                        value: '${_displayWind(weather.windSpeed)} ${_unitLabel()}',
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: AppStrings.tr(languageCode, en: 'Speed (km/h)', vi: 'Toc do (km/h)'),
                        value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: AppStrings.tr(languageCode, en: 'Speed (mph)', vi: 'Toc do (mph)'),
                        value: '${(weather.windSpeed * 0.621371).toStringAsFixed(1)} mph',
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: AppStrings.tr(languageCode, en: 'Direction', vi: 'Huong gio'),
                        value: AppStrings.tr(languageCode, en: 'Variable', vi: 'Thay doi'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getWindSpeed(double speed) {
    if (speed < 1) return AppStrings.tr(languageCode, en: 'Calm', vi: 'Lang gio');
    if (speed < 3) return AppStrings.tr(languageCode, en: 'Light', vi: 'Nhe');
    if (speed < 5) return AppStrings.tr(languageCode, en: 'Light Breeze', vi: 'Gio nhe');
    if (speed < 8) return AppStrings.tr(languageCode, en: 'Moderate', vi: 'Trung binh');
    if (speed < 11) return AppStrings.tr(languageCode, en: 'Fresh Breeze', vi: 'Gio kha manh');
    if (speed < 14) return AppStrings.tr(languageCode, en: 'Strong Breeze', vi: 'Gio manh');
    return AppStrings.tr(languageCode, en: 'Very Strong', vi: 'Rat manh');
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
