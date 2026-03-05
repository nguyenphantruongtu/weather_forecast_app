import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/services/open_meteo_service.dart';
import '../calendar_screen/providers/calendar_provider.dart';
import 'providers/statistics_provider.dart';
import 'widgets/chart_legend.dart';
import 'widgets/hero_stat_card.dart';
import 'widgets/period_selector.dart';
import 'widgets/precipitation_bar_chart.dart';
import 'widgets/temperature_line_chart.dart';
import 'widgets/uv_heatmap.dart';
import 'widgets/wind_rose_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StatisticsProvider>(
      create: (ctx) => StatisticsProvider(
        calendarProvider: ctx.read<CalendarProvider>(),
        openMeteoService: ctx.read<OpenMeteoService>(),
      )..initialize(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0B1627), Color(0xFF12233C), Color(0xFF1B3458)],
            ),
          ),
          child: SafeArea(
            child: Consumer<StatisticsProvider>(
              builder: (context, provider, _) {
                final stats = provider.current;
                return Column(
                  children: [
                    _topBar(context, provider),
                    if (provider.isLoading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    else if (stats == null)
                      Expanded(
                        child: Center(
                          child: Text(
                            'No statistics available',
                            style: GoogleFonts.inter(color: Colors.white70),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _heroGrid(provider),
                            const SizedBox(height: 14),
                            _glassCard(
                              title: 'Temperature Trend',
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 220,
                                    child: TemperatureLineChart(
                                      points: stats.temperatureTrend,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const ChartLegend(
                                    items: [
                                      MapEntry('Max', Color(0xFFFF6B6B)),
                                      MapEntry('Avg', Color(0xFFFFD93D)),
                                      MapEntry('Min', Color(0xFF4FACFE)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _glassCard(
                                    title: 'Precipitation',
                                    child: SizedBox(
                                      height: 180,
                                      child: PrecipitationBarChart(
                                        points: stats.precipitationTrend,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _glassCard(
                                    title: 'Wind Rose',
                                    child: SizedBox(
                                      height: 180,
                                      child: WindRoseChart(
                                        data: stats.windRoseData,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _glassCard(
                              title: 'UV Index Heatmap',
                              child: UvHeatmap(items: stats.uvHeatmapData),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, StatisticsProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          Text(
            'Statistics',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          const Spacer(),
          Expanded(
            child: PeriodSelector(
              selected: provider.period,
              onChanged: provider.setPeriod,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share, color: Colors.white),
            onSelected: (value) async {
              final messenger = ScaffoldMessenger.of(context);
              if (value == 'csv') {
                final path = await provider.exportCsv();
                messenger.showSnackBar(
                  SnackBar(content: Text('CSV exported: $path')),
                );
              } else {
                final path = await provider.exportPdf();
                messenger.showSnackBar(
                  SnackBar(content: Text('PDF exported: $path')),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'csv', child: Text('Export CSV')),
              PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroGrid(StatisticsProvider provider) {
    final stats = provider.current!;
    final previous = provider.previous;
    final previousAvg = previous?.avgTemp ?? stats.avgTemp;
    final previousMax = previous?.maxTemp ?? stats.maxTemp;
    final previousMin = previous?.minTemp ?? stats.minTemp;
    final previousRain = (previous?.rainyDays ?? stats.rainyDays).toDouble();

    return SizedBox(
      height: 220,
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.45,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HeroStatCard(
            title: 'Avg Temp',
            value: '${stats.avgTemp.toStringAsFixed(1)}°C',
            subtitle: 'Compared to last period',
            delta: provider.percentageDelta(stats.avgTemp, previousAvg),
          ),
          HeroStatCard(
            title: 'Max Temp',
            value: '${stats.maxTemp.toStringAsFixed(1)}°C',
            subtitle: stats.maxDateLabel,
            delta: provider.percentageDelta(stats.maxTemp, previousMax),
          ),
          HeroStatCard(
            title: 'Min Temp',
            value: '${stats.minTemp.toStringAsFixed(1)}°C',
            subtitle: stats.minDateLabel,
            delta: provider.percentageDelta(stats.minTemp, previousMin),
          ),
          HeroStatCard(
            title: 'Rainy Days',
            value: '${stats.rainyDays}',
            subtitle: stats.dominantCondition,
            delta: provider.percentageDelta(
              stats.rainyDays.toDouble(),
              previousRain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
