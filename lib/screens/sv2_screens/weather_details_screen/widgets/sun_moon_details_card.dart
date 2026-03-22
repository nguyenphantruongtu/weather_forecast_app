import 'package:flutter/material.dart';
import 'package:final_project/data/models/weather_model.dart';
import 'package:intl/intl.dart';

class SunMoonDetailsCard extends StatelessWidget {
  final WeatherModel weather;

  const SunMoonDetailsCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final sunDuration = weather.sunset.difference(weather.sunrise);
    final sunsetTime = DateFormat('hh:mm a').format(weather.sunset);
    final sunriseTime = DateFormat('hh:mm a').format(weather.sunrise);

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
              'Sun & Moon',
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
                  child: _SunMoonItem(
                    icon: Icons.wb_sunny,
                    label: 'Sunrise',
                    time: sunriseTime,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SunMoonItem(
                    icon: Icons.nights_stay,
                    label: 'Sunset',
                    time: sunsetTime,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.amber.shade50, Colors.orange.shade100],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daylight Duration',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${sunDuration.inHours}h ${sunDuration.inMinutes.remainder(60)}m',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.light_mode,
                        size: 32,
                        color: Colors.orange.shade600,
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

class _SunMoonItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  const _SunMoonItem({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
