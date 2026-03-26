import 'package:flutter/material.dart';

class WeatherBarChart extends StatelessWidget {
  const WeatherBarChart({super.key, required this.dailyTemps});

  final List<double> dailyTemps;

  @override
  Widget build(BuildContext context) {
    if (dailyTemps.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final maxTemp = dailyTemps.reduce((a, b) => a > b ? a : b);
    final minTemp = dailyTemps.reduce((a, b) => a < b ? a : b);
    final range = maxTemp - minTemp;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: dailyTemps.map((temp) {
        final normalizedHeight = range > 0
            ? ((temp - minTemp) / range) * 60 + 20
            : 40.0;

        return Container(
          width: 8,
          height: normalizedHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF007AFF),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }
}
