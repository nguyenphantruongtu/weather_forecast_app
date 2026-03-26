import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/calendar_provider.dart';
import '../../../providers/widget_config_provider.dart';
import '../../../utils/date_formatter.dart';
import '../../../utils/temperature_utils.dart';

class DateDetailBottomSheet extends StatelessWidget {
  const DateDetailBottomSheet({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final weather = provider.getWeatherForDate(date);
    final widgetTheme = context.watch<WidgetConfigProvider>().selectedTheme;
    final isDark = widgetTheme.name == 'Dark Mode';
    final sheetBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final accentColor = isDark ? Colors.white : widgetTheme.color;

    if (weather == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Text(
            'No weather data for this date',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
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
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  weather.description.split(' ').map((word) {
                    if (word.isEmpty) return word;
                    return word[0].toUpperCase() + word.substring(1);
                  }).join(' '),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.grey[600],
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
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'High / Low',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.grey[600],
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
                    color: isDark ? Colors.white : Colors.black87,
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
                      color: accentColor,
                      isDark: isDark,
                    ),
                    _buildMetricCard(
                      context: context,
                      icon: Icons.water_outlined,
                      label: 'Humidity',
                      value: '${weather.humidity}%',
                      color: accentColor,
                      isDark: isDark,
                    ),
                    _buildMetricCard(
                      context: context,
                      icon: Icons.air,
                      label: 'Wind',
                      value: '${windKmh.round()} km/h',
                      color: const Color(0xFF34C759),
                      isDark: isDark,
                    ),
                    _buildMetricCard(
                      context: context,
                      icon: Icons.wb_sunny_outlined,
                      label: 'UV Index',
                      value: '${weather.uvIndex}',
                      color: const Color(0xFFFF9500),
                      isDark: isDark,
                    ),
                    _buildMetricCard(
                      context: context,
                      icon: Icons.wb_twilight,
                      label: 'Sunrise',
                      value: DateFormat('h:mm a').format(weather.sunrise),
                      color: const Color(0xFFFF9500),
                      isDark: isDark,
                    ),
                    _buildMetricCard(
                      context: context,
                      icon: Icons.nights_stay_outlined,
                      label: 'Sunset',
                      value: DateFormat('h:mm a').format(weather.sunset),
                      color: accentColor,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3A3A3C)
                        : const Color(0xFFF5F5F5),
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
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Temperature was ${(weather.tempMax - 25).abs().round()}° ${weather.tempMax > 25 ? "above" : "below"} a rough seasonal baseline (25°C) for this date.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child:                       ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor:
                              isDark ? Colors.black87 : Colors.white,
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
                      child:                       OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: accentColor),
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
    bool isDark = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey[200]!,
        ),
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
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
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
