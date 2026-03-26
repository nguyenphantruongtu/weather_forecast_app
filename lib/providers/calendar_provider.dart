import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../data/models/month_summary_model.dart';
import '../data/models/weather_day_model.dart';
import '../data/services/weather_api_service.dart';

class _MonthCacheEntry {
  _MonthCacheEntry({required this.data, required this.fetchedAt});

  final Map<DateTime, WeatherDay> data;
  final DateTime fetchedAt;

  bool get isFresh =>
      DateTime.now().difference(fetchedAt) < const Duration(minutes: 30);
}

class CalendarProvider extends ChangeNotifier {
  CalendarProvider({required WeatherApiService apiService})
    : _apiService = apiService;

  final WeatherApiService _apiService;

  final Map<String, _MonthCacheEntry> _memoryCache = {};

  Map<DateTime, WeatherDay> _weatherData = {};
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;

  double _latitude = 21.0285;
  double _longitude = 105.8542;

  Map<DateTime, WeatherDay> get weatherData => _weatherData;
  DateTime get focusedMonth => _focusedMonth;
  DateTime? get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WeatherDay? get selectedWeather {
    if (_selectedDate == null) return null;
    return getWeatherForDate(_selectedDate!);
  }

  Future<void> initialize() async {
    await loadMonth(DateTime.now());
  }

  String _cacheKey(DateTime month) {
    final m = DateFormat('yyyy-MM').format(month);
    return '${_latitude.toStringAsFixed(4)}_${_longitude.toStringAsFixed(4)}_$m';
  }

  Future<void> loadMonth(DateTime month) async {
    _focusedMonth = DateTime(month.year, month.month);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final key = _cacheKey(_focusedMonth);
      final cached = _memoryCache[key];
      if (cached != null && cached.isFresh && cached.data.isNotEmpty) {
        _weatherData = {..._weatherData, ...cached.data};
        _isLoading = false;
        notifyListeners();
        return;
      }

      final fresh = await _apiService.fetchAppWeatherDays(
        lat: _latitude,
        lon: _longitude,
      );

      if (fresh.isEmpty) {
        _errorMessage = 'No weather data returned. Check API key and network.';
      } else {
        _weatherData = {..._weatherData, ...fresh};
        _memoryCache[key] = _MonthCacheEntry(
          data: Map<DateTime, WeatherDay>.from(fresh),
          fetchedAt: DateTime.now(),
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load weather data: $e';
      _weatherData = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = _dateOnly(date);
    notifyListeners();
  }

  WeatherDay? getWeatherForDate(DateTime date) {
    return _weatherData[_dateOnly(date)];
  }

  MonthSummary getMonthSummary() {
    final start = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final end = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    final inMonth = _weatherData.entries
        .where(
          (e) =>
              !e.key.isBefore(start) &&
              !e.key.isAfter(end),
        )
        .map((e) => e.value)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (inMonth.isEmpty) {
      return const MonthSummary(
        avgTemp: 0,
        totalRainfall: 0,
        sunnyDays: 0,
        rainyDays: 0,
        dailyAvgTemps: [],
      );
    }

    final avgTemps = inMonth
        .map((e) => (e.tempMax + e.tempMin) / 2)
        .toList();
    final avgTemp = avgTemps.reduce((a, b) => a + b) / avgTemps.length;

    final totalRainfall = inMonth
        .map((e) => e.precipitation)
        .reduce((a, b) => a + b);

    final sunnyDays = inMonth
        .where((e) => e.condition.toLowerCase() == 'clear')
        .length;
    final rainyDays = inMonth.where((e) {
      final c = e.condition.toLowerCase();
      return c == 'rain' || c == 'drizzle' || c == 'thunderstorm';
    }).length;

    return MonthSummary(
      avgTemp: avgTemp,
      totalRainfall: totalRainfall,
      sunnyDays: sunnyDays,
      rainyDays: rainyDays,
      dailyAvgTemps: avgTemps,
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void updateLocation(double lat, double lon) {
    _latitude = lat;
    _longitude = lon;
    loadMonth(_focusedMonth);
  }

  double get latitude => _latitude;
  double get longitude => _longitude;
}
