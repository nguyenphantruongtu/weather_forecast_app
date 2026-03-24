import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/weather_history_model.dart';

class CalendarProvider extends ChangeNotifier {
  static const _storagePrefix = 'weather_history_';
  static const _maxMonthCount = 3;

  Map<DateTime, WeatherHistory> weatherData = <DateTime, WeatherHistory>{};
  DateTime? selectedDate;
  bool isLoading = false;
  DateTime focusedMonth = DateTime.now();
  String? lastError;

  Future<void> loadMonth(DateTime month) async {
    focusedMonth = DateTime(month.year, month.month, 1);
    isLoading = true;
    lastError = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _monthKey(focusedMonth);
      final raw = prefs.getString(key);

      final monthData = <DateTime, WeatherHistory>{};
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is! Map<String, dynamic>) {
              if (item is Map) {
                final casted = Map<String, dynamic>.from(item);
                final weather = WeatherHistory.fromJson(casted);
                monthData[_normalizeDate(weather.date)] = weather;
              }
              continue;
            }
            final weather = WeatherHistory.fromJson(item);
            monthData[_normalizeDate(weather.date)] = weather;
          }
        }
      }

      weatherData = monthData;
      selectedDate ??= DateTime.now();
    } catch (_) {
      weatherData = <DateTime, WeatherHistory>{};
      lastError = 'Không thể tải dữ liệu lịch sử thời tiết.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveToday(WeatherHistory data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final normalizedDate = _normalizeDate(data.date);
      final key = _monthKey(normalizedDate);
      final raw = prefs.getString(key);

      final list = <WeatherHistory>[];
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              list.add(
                WeatherHistory.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
      }

      final existingIndex = list.indexWhere(
        (e) => DateUtils.isSameDay(e.date, normalizedDate),
      );
      final normalizedData = data.copyWith(date: normalizedDate);
      if (existingIndex >= 0) {
        list[existingIndex] = normalizedData;
      } else {
        list.add(normalizedData);
      }

      final payload = list.map((e) => e.toJson()).toList();
      await prefs.setString(key, jsonEncode(payload));
      await _cleanupOldMonths(prefs);

      if (focusedMonth.year == normalizedDate.year &&
          focusedMonth.month == normalizedDate.month) {
        weatherData[normalizedDate] = normalizedData;
        notifyListeners();
      }
      return true;
    } catch (_) {
      lastError = 'Lưu dữ liệu thời tiết thất bại.';
      notifyListeners();
      return false;
    }
  }

  void selectDate(DateTime date) {
    selectedDate = _normalizeDate(date);
    notifyListeners();
  }

  WeatherHistory? getWeatherForDate(DateTime date) {
    final normalized = _normalizeDate(date);
    return weatherData[normalized];
  }

  Future<void> goToPreviousMonth() async {
    await loadMonth(DateTime(focusedMonth.year, focusedMonth.month - 1, 1));
  }

  Future<void> goToNextMonth() async {
    await loadMonth(DateTime(focusedMonth.year, focusedMonth.month + 1, 1));
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _monthKey(DateTime date) {
    return '$_storagePrefix${DateFormat('yyyy-MM').format(date)}';
  }

  Future<void> _cleanupOldMonths(SharedPreferences prefs) async {
    final monthKeys =
        prefs.getKeys().where((k) => k.startsWith(_storagePrefix)).toList()
          ..sort();

    if (monthKeys.length <= _maxMonthCount) return;

    final deleteCount = monthKeys.length - _maxMonthCount;
    for (var i = 0; i < deleteCount; i++) {
      await prefs.remove(monthKeys[i]);
    }
  }
}
