import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/services/open_meteo_service.dart';
import '../../calendar_screen/providers/calendar_provider.dart';
import '../models/weather_statistics_model.dart';
import '../utils/export_helper.dart';
import '../utils/statistics_calculator.dart';

enum StatisticsPeriod { week, month, threeMonths, year }

class StatisticsProvider extends ChangeNotifier {
  StatisticsProvider({
    required CalendarProvider calendarProvider,
    required OpenMeteoService openMeteoService,
  })  : _calendarProvider = calendarProvider,
        _openMeteoService = openMeteoService;

  static const _defaultLat = 21.0278;
  static const _defaultLon = 105.8342;

  final CalendarProvider _calendarProvider;
  final OpenMeteoService _openMeteoService;

  StatisticsPeriod _period = StatisticsPeriod.month;
  bool _isLoading = false;
  WeatherStatisticsModel? _current;
  WeatherStatisticsModel? _previous;
  Timer? _debounce;

  StatisticsPeriod get period => _period;
  bool get isLoading => _isLoading;
  WeatherStatisticsModel? get current => _current;
  WeatherStatisticsModel? get previous => _previous;

  Future<void> initialize() async {
    await recalculate();
  }

  void setPeriod(StatisticsPeriod value) {
    _period = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      recalculate();
    });
    notifyListeners();
  }

  Future<void> recalculate() async {
    _isLoading = true;
    notifyListeners();
    final now = DateTime.now();
    final start = _periodStart(now, _period);
    final previousStart = _periodStart(
      start.subtract(const Duration(days: 1)),
      _period,
    );
    final previousEnd = start.subtract(const Duration(days: 1));

    try {
      final data = await _openMeteoService.fetchDailyHistory(
        lat: _defaultLat,
        lon: _defaultLon,
        startDate: start,
        endDate: now,
      );
      final previousData = await _openMeteoService.fetchDailyHistory(
        lat: _defaultLat,
        lon: _defaultLon,
        startDate: previousStart,
        endDate: previousEnd,
      );
      _current = StatisticsCalculator.build(data);
      _previous = StatisticsCalculator.build(previousData);
    } catch (_) {
      _current = null;
      _previous = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DateTime _periodStart(DateTime anchor, StatisticsPeriod period) {
    switch (period) {
      case StatisticsPeriod.week:
        return anchor.subtract(const Duration(days: 6));
      case StatisticsPeriod.month:
        return DateTime(anchor.year, anchor.month, 1);
      case StatisticsPeriod.threeMonths:
        return DateTime(anchor.year, anchor.month - 2, 1);
      case StatisticsPeriod.year:
        return DateTime(anchor.year, 1, 1);
    }
  }

  double percentageDelta(double current, double previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  Future<String> exportCsv() async {
    final now = DateTime.now();
    final start = _periodStart(now, _period);
    final data = await _openMeteoService.fetchDailyHistory(
      lat: _defaultLat,
      lon: _defaultLon,
      startDate: start,
      endDate: now,
    );
    return ExportHelper.exportCsv(data);
  }

  Future<String> exportPdf() async {
    if (_current == null) {
      await recalculate();
    }
    return ExportHelper.exportPdf(_current!);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
