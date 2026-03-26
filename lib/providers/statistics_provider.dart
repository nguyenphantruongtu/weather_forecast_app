import 'package:flutter/foundation.dart';

import '../data/models/statistics_model.dart';
import 'calendar_provider.dart';

class StatisticsProvider extends ChangeNotifier {
  StatisticsProvider({required this.calendarProvider}) {
    calendarProvider.addListener(_onCalendarChanged);
    calculateStatistics();
  }

  final CalendarProvider calendarProvider;

  String _selectedPeriod = 'Month';
  WeatherStatistics? _statistics;

  String get selectedPeriod => _selectedPeriod;
  WeatherStatistics? get statistics => _statistics;

  void _onCalendarChanged() {
    calculateStatistics();
    notifyListeners();
  }

  @override
  void dispose() {
    calendarProvider.removeListener(_onCalendarChanged);
    super.dispose();
  }

  void selectPeriod(String period) {
    _selectedPeriod = period;
    calculateStatistics();
    notifyListeners();
  }

  void calculateStatistics() {
    final weatherData = calendarProvider.weatherData;
    if (weatherData.isEmpty) {
      _statistics = null;
      return;
    }

    final now = DateTime.now();
    DateTime startDate;
    DateTime? prevStart;
    DateTime? prevEnd;

    switch (_selectedPeriod) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        prevStart = now.subtract(const Duration(days: 14));
        prevEnd = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        prevStart = DateTime(now.year, now.month - 1, 1);
        prevEnd = DateTime(now.year, now.month, 0);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        prevStart = DateTime(now.year - 1, 1, 1);
        prevEnd = DateTime(now.year - 1, 12, 31);
        break;
      case 'All':
      default:
        startDate = weatherData.keys.reduce((a, b) => a.isBefore(b) ? a : b);
        prevStart = null;
        prevEnd = null;
    }

    DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
    final startNorm = dayOnly(startDate);
    final nowNorm = dayOnly(now);

    final filteredEntries = weatherData.entries.where((e) {
      final k = dayOnly(e.key);
      if (_selectedPeriod == 'Week') {
        return !k.isBefore(startNorm) && !k.isAfter(nowNorm);
      }
      if (_selectedPeriod == 'Month') {
        return k.year == now.year && k.month == now.month;
      }
      if (_selectedPeriod == 'Year') {
        return k.year == now.year;
      }
      return !k.isBefore(startNorm);
    }).toList();

    if (filteredEntries.isEmpty) {
      _statistics = null;
      return;
    }

    final filteredData = filteredEntries.map((e) => e.value).toList();

    final avgTemps = filteredData
        .map((e) => (e.tempMax + e.tempMin) / 2)
        .toList();
    final avgTemp = avgTemps.reduce((a, b) => a + b) / avgTemps.length;

    final maxEntry = filteredData.reduce(
      (a, b) => a.tempMax > b.tempMax ? a : b,
    );
    final minEntry = filteredData.reduce(
      (a, b) => a.tempMin < b.tempMin ? a : b,
    );

    final tempTrend = filteredData.map((day) {
      return TempDataPoint(
        date: day.date,
        maxTemp: day.tempMax,
        avgTemp: (day.tempMax + day.tempMin) / 2,
        minTemp: day.tempMin,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    double comparisonDiff = 0;
    var comparisonUp = false;
    if (prevStart != null && prevEnd != null) {
      final ps = dayOnly(prevStart);
      final pe = dayOnly(prevEnd);
      final prevDays = weatherData.entries
          .where((e) {
            final k = dayOnly(e.key);
            return !k.isBefore(ps) && !k.isAfter(pe);
          })
          .map((e) => e.value)
          .toList();
      if (prevDays.isNotEmpty) {
        final prevAvg = prevDays
                .map((e) => (e.tempMax + e.tempMin) / 2)
                .reduce((a, b) => a + b) /
            prevDays.length;
        comparisonDiff = (avgTemp - prevAvg).abs();
        comparisonUp = avgTemp > prevAvg;
      }
    }

    _statistics = WeatherStatistics(
      period: _selectedPeriod,
      avgTemp: avgTemp,
      maxTemp: maxEntry.tempMax,
      maxTempDate: maxEntry.date,
      minTemp: minEntry.tempMin,
      minTempDate: minEntry.date,
      tempTrend: tempTrend,
      comparisonDiff: comparisonDiff,
      comparisonUp: comparisonUp,
    );
  }
}
