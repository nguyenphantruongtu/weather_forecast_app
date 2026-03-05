import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/services/weather_api_service.dart';
import '../models/calendar_weather_model.dart';
import '../models/weather_day_model.dart';
import '../utils/date_utils.dart';

class CalendarProvider extends ChangeNotifier {
  CalendarProvider({required WeatherApiService weatherApiService})
    : _weatherApiService = weatherApiService;

  static const _storageKey = 'sv5_weather_history_v1';
  static const _lastFetchKey = 'sv5_last_weather_fetch';
  static const _defaultLat = 21.0278;
  static const _defaultLon = 105.8342;

  final WeatherApiService _weatherApiService;
  final Map<String, WeatherDayModel> _cache = <String, WeatherDayModel>{};

  DateTime _focusedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime _selectedDate = CalendarDateUtils.normalize(DateTime.now());
  bool _isLoading = false;
  String? _errorMessage;

  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<WeatherDayModel> get currentMonthData {
    return _cache.values
        .where(
          (item) =>
              item.date.year == _focusedMonth.year &&
              item.date.month == _focusedMonth.month,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Map<DateTime, WeatherDayModel> get monthDataMap {
    final map = <DateTime, WeatherDayModel>{};
    for (final item in currentMonthData) {
      map[CalendarDateUtils.normalize(item.date)] = item;
    }
    return map;
  }

  CalendarWeatherSummary get monthlySummary =>
      CalendarWeatherSummary.fromDays(currentMonthData);

  /// Dự báo 5 ngày (hôm nay + 4 ngày tới) hoặc tối đa 6 ngày nếu API trả đủ.
  List<WeatherDayModel> get forecastDays {
    final now = DateTime.now();
    final today = CalendarDateUtils.normalize(now);
    final end = today.add(const Duration(days: 5));
    return _cache.values
        .where((d) {
          final n = CalendarDateUtils.normalize(d.date);
          return !n.isBefore(today) && !n.isAfter(end);
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> initialize() async {
    await _loadFromStorage();
    await ensureTodayData();
    await loadMonth(_focusedMonth);
  }

  Future<void> loadMonth(DateTime month) async {
    _focusedMonth = DateTime(month.year, month.month, 1);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadFromStorage();
      await _hydrateHistoricalMonthIfNeeded(_focusedMonth);
    } catch (_) {
      _errorMessage = 'Không thể tải dữ liệu theo tháng.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> goToPreviousMonth() async {
    await loadMonth(DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1));
  }

  Future<void> goToNextMonth() async {
    await loadMonth(DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1));
  }

  void selectDate(DateTime date) {
    _selectedDate = CalendarDateUtils.normalize(date);
    notifyListeners();
  }

  void jumpToDate(DateTime date) {
    _selectedDate = CalendarDateUtils.normalize(date);
    _focusedMonth = DateTime(date.year, date.month, 1);
    notifyListeners();
  }

  WeatherDayModel? getWeatherForDate(DateTime date) {
    return _cache[CalendarDateUtils.dayKey(date)];
  }

  Future<void> ensureTodayData() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = CalendarDateUtils.dayKey(DateTime.now());
    final lastFetch = prefs.getString(_lastFetchKey);
    final hasTodayInCache = _cache.containsKey(todayKey);
    final skip = lastFetch == todayKey && hasTodayInCache;
    if (skip) return;

    try {
      await fetchAndSaveTodayWeather();
      _errorMessage = null;
      await prefs.setString(_lastFetchKey, todayKey);
    } catch (_) {
      _errorMessage = 'Không thể tải thời tiết. Kiểm tra API key (.env) và mạng.';
      notifyListeners();
    }
  }

  /// Gọi thủ công để đồng bộ lại dữ liệu hôm nay (bỏ qua cache).
  Future<bool> refreshToday() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastFetchKey);
      await fetchAndSaveTodayWeather();
      final todayKey = CalendarDateUtils.dayKey(DateTime.now());
      await prefs.setString(_lastFetchKey, todayKey);
      return true;
    } catch (_) {
      _errorMessage = 'Không thể tải thời tiết. Kiểm tra API key (.env) và mạng.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAndSaveTodayWeather() async {
    final items = await _weatherApiService.fetchTodayWithForecast(
      lat: _defaultLat,
      lon: _defaultLon,
    );
    for (final day in items) {
      _cache[CalendarDateUtils.dayKey(day.date)] = day;
    }
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> _hydrateHistoricalMonthIfNeeded(DateTime month) async {
    final now = DateTime.now();
    if (month.year != now.year || month.month != now.month) {
      return;
    }

    final monthDays = CalendarDateUtils.daysInMonth(month);
    final missingPastDays = monthDays
        .where(
          (d) =>
              d.isBefore(now) &&
              !_cache.containsKey(CalendarDateUtils.dayKey(d)),
        )
        .toList();

    if (missingPastDays.isEmpty) return;
    final fetchCount = missingPastDays.length > 2 ? 2 : missingPastDays.length;
    for (var i = 0; i < fetchCount; i++) {
      final day = missingPastDays[i];
      final historical = await _weatherApiService.fetchHistoricalDay(
        lat: _defaultLat,
        lon: _defaultLon,
        date: day,
      );
      if (historical != null) {
        _cache[CalendarDateUtils.dayKey(day)] = historical;
      }
    }
    await _saveToStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    _cache.clear();
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is Map) {
        _cache[entry.key] = WeatherDayModel.fromJson(
          Map<String, dynamic>.from(value),
        );
      }
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{};
    for (final entry in _cache.entries) {
      payload[entry.key] = entry.value.toJson();
    }
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  Future<String> exportCurrentMonthToCsv() async {
    final rows = <List<dynamic>>[
      <dynamic>[
        'Date',
        'Condition',
        'Temp',
        'Max',
        'Min',
        'Humidity',
        'Wind Speed',
        'Precipitation',
        'UV Index',
      ],
      ...currentMonthData.map(
        (d) => <dynamic>[
          DateFormat('yyyy-MM-dd').format(d.date),
          d.condition,
          d.temp.toStringAsFixed(1),
          d.tempMax.toStringAsFixed(1),
          d.tempMin.toStringAsFixed(1),
          d.humidity,
          d.windSpeed.toStringAsFixed(1),
          d.precipitationAmount.toStringAsFixed(1),
          d.uvIndex.toStringAsFixed(1),
        ],
      ),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final monthLabel = DateFormat('yyyy_MM').format(_focusedMonth);
    final file = File('${dir.path}/weather_calendar_$monthLabel.csv');
    await file.create(recursive: true);
    await file.writeAsString(csv);
    return file.path;
  }

  Future<void> shareCurrentMonthSummary() async {
    final summary = monthlySummary;
    final monthLabel = DateFormat('MMMM yyyy').format(_focusedMonth);
    final message =
        'Weather summary $monthLabel\n'
        'Average temp: ${summary.averageTemp.toStringAsFixed(1)}°C\n'
        'Rainy days: ${summary.rainyDays}\n'
        'Hottest: ${summary.hottestDay?.tempMax.toStringAsFixed(1) ?? '-'}°C\n'
        'Coldest: ${summary.coldestDay?.tempMin.toStringAsFixed(1) ?? '-'}°C';
    await Share.share(message, subject: 'Weather calendar summary');
  }

  Future<List<WeatherDayModel>> getDataForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    await _loadFromStorage();
    final normalizedStart = CalendarDateUtils.normalize(start);
    final normalizedEnd = CalendarDateUtils.normalize(end);
    final list = _cache.values.where((item) {
      final d = CalendarDateUtils.normalize(item.date);
      return (d.isAfter(normalizedStart) || d == normalizedStart) &&
          (d.isBefore(normalizedEnd) || d == normalizedEnd);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }
}
