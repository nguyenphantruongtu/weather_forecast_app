import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/statistics_provider.dart';
import '../../providers/weather_provider.dart';
import 'widgets/comparison_indicator.dart';
import 'widgets/period_selector.dart';
import 'widgets/temperature_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Weather Statistics',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<StatisticsProvider, WeatherProvider>(
        builder: (context, statsProv, weatherProv, child) {
          final locationName =
              weatherProv.currentWeather?.location ?? 'Hanoi, Vietnam';
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const PeriodSelector(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        locationName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (statsProv.selectedPeriod == 'All') ...[
                  _buildSectionTitle('Week'),
                  if (statsProv.weekStatistics != null)
                    TemperatureChart(stats: statsProv.weekStatistics!),
                  if (statsProv.weekStatistics != null)
                    ComparisonIndicator(stats: statsProv.weekStatistics!),
                  const SizedBox(height: 10),
                  _buildSectionTitle('Month'),
                  if (statsProv.monthStatistics != null)
                    TemperatureChart(stats: statsProv.monthStatistics!),
                  if (statsProv.monthStatistics != null)
                    ComparisonIndicator(stats: statsProv.monthStatistics!),
                  const SizedBox(height: 10),
                  _buildSectionTitle('Year'),
                  if (statsProv.yearStatistics != null)
                    TemperatureChart(stats: statsProv.yearStatistics!),
                  if (statsProv.yearStatistics != null)
                    ComparisonIndicator(stats: statsProv.yearStatistics!),
                ] else ...[
                  if (statsProv.statistics != null)
                    TemperatureChart(stats: statsProv.statistics!),
                  if (statsProv.statistics != null)
                    ComparisonIndicator(stats: statsProv.statistics!),
                  if (statsProv.statistics == null)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No statistics for this period',
                        style: GoogleFonts.inter(color: Colors.grey[700]),
                      ),
                    ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
