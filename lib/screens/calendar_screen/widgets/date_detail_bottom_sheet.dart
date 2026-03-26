import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/calendar_provider.dart';
import '../../../utils/date_formatter.dart';
import '../../../utils/temperature_utils.dart';

class DateDetailBottomSheet extends StatelessWidget {
  const DateDetailBottomSheet({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final weather = provider.getWeatherForDate(date);

    if (weather == null) {
      return Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Text('No weather data for this date'),
        ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        final windKmh = TemperatureUtils.windMsToKmh(weather.windSpeed);
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppDateFormatter.fullDate(date),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  weather.description.split(' ').map((word) {
                    if (word.isEmpty) return word;
                    return word[0].toUpperCase() + word.substring(1);
                  }).join(' '),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(weather.icon, style: const TextStyle(fontSize: 64)),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.tempMax.round()}° / ${weather.tempMin.round()}°',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          'High / Low',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Detailed Metrics',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildMetricCard(
                      context: context,
                      icon: Icons.water_drop_outlined,
                      label: 'Precipitation',
                      value: '${weather.precipitation.round()} mm',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _buildMetricCard(
                      context: context,
                      icon: Icons.water_outlined,
                      label: 'Humidity',
                      value: '${weather.humidity}%',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _buildMetricCard(
                      context: context,
                      icon: Icons.air,
                      label: 'Wind',
                      value: '${windKmh.round()} km/h',
                      color: const Color(0xFF34C759),
                    ),
                    _buildMetricCard(
                      context: context,
                      icon: Icons.wb_sunny_outlined,
                      label: 'UV Index',
                      value: '${weather.uvIndex}',
                      color: const Color(0xFFFF9500),
                    ),
                    _buildMetricCard(
                      context: context,
                      icon: Icons.wb_twilight,
                      label: 'Sunrise',
                      value: DateFormat('h:mm a').format(weather.sunrise),
                      color: const Color(0xFFFF9500),
                    ),
                    _buildMetricCard(
                      context: context,
                      icon: Icons.nights_stay_outlined,
                      label: 'Sunset',
                      value: DateFormat('h:mm a').format(weather.sunset),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historical Data',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Temperature was ${(weather.tempMax - 25).abs().round()}° ${weather.tempMax > 25 ? "above" : "below"} a rough seasonal baseline (25°C) for this date.',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Compare to Today'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
