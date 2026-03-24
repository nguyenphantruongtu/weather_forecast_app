import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../statistics_screen/statistics_screen.dart';
import 'models/calendar_weather_model.dart';
import 'providers/calendar_provider.dart';
import 'widgets/date_detail_sheet.dart';
import 'widgets/five_day_forecast_list.dart';
import 'widgets/five_day_summary_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1B2B), Color(0xFF1E3A5F), Color(0xFF29405A)],
          ),
        ),
        child: SafeArea(
          child: Consumer<CalendarProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.forecastDays.isEmpty) {
                return const _LoadingView();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildTopBar(context, provider),
                    if (provider.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      _buildErrorBanner(context, provider),
                    ],
                    const SizedBox(height: 12),
                    if (provider.forecastDays.isNotEmpty) ...[
                      FiveDaySummaryCard(
                        summary: CalendarWeatherSummary.fromDays(
                          provider.forecastDays,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FiveDayForecastList(
                        days: provider.forecastDays,
                        selectedDate: provider.selectedDate,
                        onDaySelected: provider.selectDate,
                      ),
                    ] else
                      _buildEmptyForecast(context, provider),
                    const SizedBox(height: 12),
                    Expanded(child: _buildDetail(provider)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, CalendarProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Dự báo thời tiết',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Đồng bộ dự báo 5 ngày',
          onPressed: provider.isLoading ? null : () => _syncWeather(context, provider),
          icon: provider.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.cloud_download, color: Colors.white),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.ios_share, color: Colors.white),
          onSelected: (value) async {
            if (value == 'csv') {
              final path = await provider.exportCurrentMonthToCsv();
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Exported CSV: $path')));
            } else {
              await provider.shareCurrentMonthSummary();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'csv', child: Text('Export CSV')),
            PopupMenuItem(value: 'share', child: Text('Share summary')),
          ],
        ),
        IconButton(
          tooltip: 'Statistics',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StatisticsScreen()),
          ),
          icon: const Icon(Icons.query_stats, color: Colors.white),
        ),
      ],
    );
  }

  Future<void> _syncWeather(BuildContext context, CalendarProvider provider) async {
    final ok = await provider.refreshToday();
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(const SnackBar(content: Text('Đã đồng bộ thời tiết hôm nay.')));
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(provider.errorMessage ?? 'Đồng bộ thất bại.'),
        action: SnackBarAction(label: 'Thử lại', onPressed: () => _syncWeather(context, provider)),
      ));
    }
  }

  Widget _buildErrorBanner(BuildContext context, CalendarProvider provider) {
    return Material(
      color: Colors.orange.shade900.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                provider.errorMessage ?? '',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () => _syncWeather(context, provider),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(CalendarProvider provider) {
    final weather = provider.getWeatherForDate(provider.selectedDate);
    if (weather == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 48, color: Colors.white38),
              const SizedBox(height: 12),
              Text(
                'Chưa có dữ liệu cho ${DateFormat('dd MMM').format(provider.selectedDate)}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn ngày hôm nay và bấm nút đồng bộ (☁) để tải thời tiết.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: DateDetailSheet(
        key: ValueKey(weather.dateKey),
        weather: weather,
        onSwipePrevious: () => provider.selectDate(
          provider.selectedDate.subtract(const Duration(days: 1)),
        ),
        onSwipeNext: () => provider.selectDate(
          provider.selectedDate.add(const Duration(days: 1)),
        ),
      ),
    );
  }

  Widget _buildEmptyForecast(BuildContext context, CalendarProvider provider) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 56, color: Colors.white38),
              const SizedBox(height: 16),
              Text(
                'Chưa có dữ liệu dự báo',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bấm nút đồng bộ (☁) để tải dự báo 5 ngày tới.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () => _syncWeather(context, provider),
                icon: const Icon(Icons.cloud_download),
                label: const Text('Tải dự báo'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4FACFE),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.white10,
            highlightColor: Colors.white30,
            child: Container(
              height: 360,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: Colors.white10,
            highlightColor: Colors.white30,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
