import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/forecast_model.dart';

class HourlyItem extends StatelessWidget {
  final ForecastModel forecast;
  final bool isSelected;
  final VoidCallback onTap;

  const HourlyItem({
    Key? key,
    required this.forecast,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

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
      default:
        return '🌤️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(forecast.dt);
    final time = DateFormat('HH:mm').format(dateTime);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.shade400
              : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blue.shade600
                : Colors.blue.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getWeatherIcon(forecast.description),
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              '${forecast.temp.toStringAsFixed(0)}°',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${forecast.tempMin.toStringAsFixed(0)}° ~ ${forecast.tempMax.toStringAsFixed(0)}°',
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.opacity,
                  size: 12,
                  color: isSelected ? Colors.white : Colors.blue,
                ),
                const SizedBox(width: 2),
                Text(
                  '${forecast.humidity}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
