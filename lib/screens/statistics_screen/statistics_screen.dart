import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/calendar_provider.dart';
import '../../providers/statistics_provider.dart';
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
      body: Consumer2<CalendarProvider, StatisticsProvider>(
        builder: (context, calendar, statsProv, child) {
          if (calendar.isLoading && calendar.weatherData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (calendar.weatherData.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Open the Calendar tab and pull to refresh or wait for data to load.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final stats = statsProv.statistics;
          if (stats == null) {
            return Center(
              child: Text(
                'No statistics for this period',
                style: GoogleFonts.inter(color: Colors.grey[700]),
              ),
            );
          }

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
                        'Hanoi, Vietnam',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TemperatureChart(stats: stats),
                ComparisonIndicator(stats: stats),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
