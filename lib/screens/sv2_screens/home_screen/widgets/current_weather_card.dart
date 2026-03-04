import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/weather_model.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const CurrentWeatherCard({Key? key, required this.weather}) : super(key: key);

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
                    DateFormat(
                      'EEE, MMM d • h:mm a',
                    ).format(weather.lastUpdated),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
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
                    '${weather.temperature.toStringAsFixed(0)}°',
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
                    'Feels like ${weather.feelsLike.toStringAsFixed(0)}°',
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
