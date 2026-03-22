import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/data/models/forecast_model.dart';
import 'package:final_project/utils/weather_icon_mapper.dart';

class DailyForecastCard extends StatelessWidget {
  final ForecastModel forecast;
  final int dayNumber;

  const DailyForecastCard({
    super.key,
    required this.forecast,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(forecast.dt);
    final dateFormatted = DateFormat('MMM d, EEE').format(dateTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Date and day number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day $dayNumber',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        dateFormatted,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    WeatherIconMapper.getWeatherEmoji(forecast.description),
                    style: const TextStyle(fontSize: 32),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),

              // Temperature info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Temperature',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        '${forecast.tempMax.toStringAsFixed(1)}° / ${forecast.tempMin.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Feels Like',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        '${forecast.feelsLike.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Weather metrics grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _MetricItem(
                    icon: Icons.cloud,
                    label: 'Cloud',
                    value: '${forecast.cloudiness}%',
                  ),
                  _MetricItem(
                    icon: Icons.opacity,
                    label: 'Humidity',
                    value: '${forecast.humidity}%',
                  ),
                  _MetricItem(
                    icon: Icons.water_drop,
                    label: 'Precip',
                    value:
                        '${(forecast.precipitation * 100).toStringAsFixed(0)}%',
                  ),
                  _MetricItem(
                    icon: Icons.air,
                    label: 'Wind',
                    value: '${forecast.windSpeed.toStringAsFixed(1)} m/s',
                  ),
                  _MetricItem(
                    icon: Icons.cloud_queue,
                    label: 'Desc',
                    value: forecast.description,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade600),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
