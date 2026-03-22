import 'package:flutter/material.dart';
import 'package:final_project/data/models/weather_model.dart';

class WindDetailsCard extends StatelessWidget {
  final WeatherModel weather;

  const WindDetailsCard({super.key, required this.weather});

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
            const Text(
              'Wind Details',
              style: TextStyle(
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
                                '${weather.windSpeed.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'm/s',
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
                        label: 'Speed',
                        value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Speed (km/h)',
                        value:
                            '${(weather.windSpeed * 3.6).toStringAsFixed(1)} km/h',
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Speed (mph)',
                        value:
                            '${(weather.windSpeed * 2.237).toStringAsFixed(1)} mph',
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(label: 'Direction', value: 'Variable'),
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
    if (speed < 1) return 'Calm';
    if (speed < 3) return 'Light';
    if (speed < 5) return 'Light Breeze';
    if (speed < 8) return 'Moderate';
    if (speed < 11) return 'Fresh Breeze';
    if (speed < 14) return 'Strong Breeze';
    return 'Very Strong';
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
