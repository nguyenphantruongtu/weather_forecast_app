import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/forecast_model.dart';

class ForecastPreview extends StatelessWidget {
  final List<ForecastModel> hourlyForecast;

  const ForecastPreview({Key? key, required this.hourlyForecast})
    : super(key: key);

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
    if (hourlyForecast.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get next 4 hours
    List<ForecastModel> nextHours = hourlyForecast.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hourly Forecast',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to hourly forecast screen
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(nextHours.length, (index) {
              final forecast = nextHours[index];
              return Container(
                margin: EdgeInsets.only(
                  right: index == nextHours.length - 1 ? 0 : 12,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(DateTime.parse(forecast.dt)),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
