import 'package:flutter/foundation.dart';

import '../data/models/statistics_model.dart';
import 'calendar_provider.dart';

class StatisticsProvider extends ChangeNotifier {
  StatisticsProvider({required this.calendarProvider}) {
    _statisticsByPeriod = _buildHardcodedStatistics();
    _statistics = _statisticsByPeriod[_selectedPeriod];
  }

  // Kept for constructor compatibility in main.dart, but not used for chart data.
  final CalendarProvider calendarProvider;
  late final Map<String, WeatherStatistics> _statisticsByPeriod;

  String _selectedPeriod = 'Month';
  WeatherStatistics? _statistics;

  String get selectedPeriod => _selectedPeriod;
  WeatherStatistics? get statistics => _statistics;
  WeatherStatistics? get weekStatistics => _statisticsByPeriod['Week'];
  WeatherStatistics? get monthStatistics => _statisticsByPeriod['Month'];
  WeatherStatistics? get yearStatistics => _statisticsByPeriod['Year'];

  @override
  void dispose() {
    super.dispose();
  }

  void selectPeriod(String period) {
    _selectedPeriod = period;
    _statistics = _statisticsByPeriod[period];
    notifyListeners();
  }

  Map<String, WeatherStatistics> _buildHardcodedStatistics() {
    final now = DateTime.now();

    final weekPoints = <TempDataPoint>[
      for (int i = 6; i >= 0; i--)
        TempDataPoint(
          date: DateTime(now.year, now.month, now.day).subtract(
            Duration(days: i),
          ),
          maxTemp: [31, 32, 33, 34, 35, 34, 36][6 - i].toDouble(),
          avgTemp: [27, 27, 28, 29, 30, 30, 31][6 - i].toDouble(),
          minTemp: [24, 23, 23, 24, 24, 25, 25][6 - i].toDouble(),
        ),
    ];

    final monthPoints = <TempDataPoint>[
      TempDataPoint(
        date: DateTime(now.year, now.month, 1),
        maxTemp: 30,
        avgTemp: 27,
        minTemp: 24,
      ),
      TempDataPoint(
        date: DateTime(now.year, now.month, 6),
        maxTemp: 31,
        avgTemp: 27,
        minTemp: 23,
      ),
      TempDataPoint(
        date: DateTime(now.year, now.month, 11),
        maxTemp: 29,
        avgTemp: 26,
        minTemp: 22,
      ),
      TempDataPoint(
        date: DateTime(now.year, now.month, 16),
        maxTemp: 30,
        avgTemp: 26,
        minTemp: 23,
      ),
      TempDataPoint(
        date: DateTime(now.year, now.month, 21),
        maxTemp: 33,
        avgTemp: 28,
        minTemp: 23.5,
      ),
      TempDataPoint(
        date: DateTime(now.year, now.month, 26),
        maxTemp: 35,
        avgTemp: 29,
        minTemp: 24,
      ),
      TempDataPoint(
        date: DateTime(now.year, now.month, 31),
        maxTemp: 36,
        avgTemp: 30,
        minTemp: 23.5,
      ),
    ];

    final yearPoints = <TempDataPoint>[
      TempDataPoint(date: DateTime(now.year, 1, 1), maxTemp: 23, avgTemp: 19, minTemp: 15),
      TempDataPoint(date: DateTime(now.year, 2, 1), maxTemp: 24, avgTemp: 20, minTemp: 16),
      TempDataPoint(date: DateTime(now.year, 3, 1), maxTemp: 27, avgTemp: 23, minTemp: 19),
      TempDataPoint(date: DateTime(now.year, 4, 1), maxTemp: 31, avgTemp: 27, minTemp: 23),
      TempDataPoint(date: DateTime(now.year, 5, 1), maxTemp: 34, avgTemp: 29, minTemp: 25),
      TempDataPoint(date: DateTime(now.year, 6, 1), maxTemp: 35, avgTemp: 30, minTemp: 26),
      TempDataPoint(date: DateTime(now.year, 7, 1), maxTemp: 36, avgTemp: 31, minTemp: 27),
      TempDataPoint(date: DateTime(now.year, 8, 1), maxTemp: 35, avgTemp: 30, minTemp: 26),
      TempDataPoint(date: DateTime(now.year, 9, 1), maxTemp: 33, avgTemp: 28, minTemp: 24),
      TempDataPoint(date: DateTime(now.year, 10, 1), maxTemp: 31, avgTemp: 26, minTemp: 22),
      TempDataPoint(date: DateTime(now.year, 11, 1), maxTemp: 28, avgTemp: 23, minTemp: 19),
      TempDataPoint(date: DateTime(now.year, 12, 1), maxTemp: 25, avgTemp: 21, minTemp: 17),
    ];

    WeatherStatistics makeStats({
      required String period,
      required List<TempDataPoint> points,
      required double comparisonDiff,
      required bool comparisonUp,
    }) {
      final avg = points.map((e) => e.avgTemp).reduce((a, b) => a + b) / points.length;
      final maxPoint = points.reduce((a, b) => a.maxTemp >= b.maxTemp ? a : b);
      final minPoint = points.reduce((a, b) => a.minTemp <= b.minTemp ? a : b);
      return WeatherStatistics(
        period: period,
        avgTemp: avg,
        maxTemp: maxPoint.maxTemp,
        maxTempDate: maxPoint.date,
        minTemp: minPoint.minTemp,
        minTempDate: minPoint.date,
        tempTrend: points,
        comparisonDiff: comparisonDiff,
        comparisonUp: comparisonUp,
      );
    }

    return {
      'Week': makeStats(
        period: 'Week',
        points: weekPoints,
        comparisonDiff: 1.2,
        comparisonUp: true,
      ),
      'Month': makeStats(
        period: 'Month',
        points: monthPoints,
        comparisonDiff: 0.8,
        comparisonUp: true,
      ),
      'Year': makeStats(
        period: 'Year',
        points: yearPoints,
        comparisonDiff: 0.5,
        comparisonUp: false,
      ),
    };
  }
}
