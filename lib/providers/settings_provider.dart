import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/settings_model.dart';

/// Provider quản lý cài đặt ứng dụng
/// Sử dụng ChangeNotifier từ package provider để thông báo khi cài đặt thay đổi
/// Lưu dữ liệu vào SharedPreferences (bộ nhớ local)
class SettingsProvider extends ChangeNotifier {
  SettingsModel _settings = SettingsModel();
  late SharedPreferences _prefs;

  SettingsModel get settings => _settings;

  /// Khởi tạo provider (gọi từ main.dart hoặc trong MultiProvider)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  /// Tải cài đặt từ SharedPreferences
  Future<void> _loadSettings() async {
    try {
      // Tải temperature unit
      final tempUnitStr = _prefs.getString('temperatureUnit') ?? 'celsius';
      _settings.temperatureUnit = tempUnitStr == 'celsius'
          ? TemperatureUnit.celsius
          : TemperatureUnit.fahrenheit;

      // Tải wind speed unit
      final windUnitStr = _prefs.getString('windSpeedUnit') ?? 'kmh';
      _settings.windSpeedUnit =
          windUnitStr == 'kmh' ? WindSpeedUnit.kmh : WindSpeedUnit.mph;

      // Tải theme
      final themeStr = _prefs.getString('theme') ?? 'light';
      _settings.theme =
          themeStr == 'light' ? AppTheme.light : AppTheme.dark;

      // Tải time format
      final timeFormatStr = _prefs.getString('timeFormat') ?? 'h24';
      _settings.timeFormat =
          timeFormatStr == 'h24' ? TimeFormat.h24 : TimeFormat.h12;

      // Tải language
      _settings.language = _prefs.getString('language') ?? 'en';

      notifyListeners();
      // notifyListeners: thông báo tất cả listener rằng dữ liệu đã thay đổi
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  /// Cập nhật temperature unit
  void updateTemperatureUnit(TemperatureUnit unit) {
    _settings.temperatureUnit = unit;
    _prefs.setString(
      'temperatureUnit',
      unit == TemperatureUnit.celsius ? 'celsius' : 'fahrenheit',
    );
    notifyListeners();
  }

  /// Cập nhật wind speed unit
  void updateWindUnit(WindSpeedUnit unit) {
    _settings.windSpeedUnit = unit;
    _prefs.setString(
      'windSpeedUnit',
      unit == WindSpeedUnit.kmh ? 'kmh' : 'mph',
    );
    notifyListeners();
  }

  /// Cập nhật theme
  void updateTheme(AppTheme theme) {
    _settings.theme = theme;
    _prefs.setString(
      'theme',
      theme == AppTheme.light ? 'light' : 'dark',
    );
    notifyListeners();
  }

  /// Cập nhật time format
  void updateTimeFormat(TimeFormat format) {
    _settings.timeFormat = format;
    _prefs.setString(
      'timeFormat',
      format == TimeFormat.h24 ? 'h24' : 'h12',
    );
    notifyListeners();
  }

  /// Cập nhật language
  void updateLanguage(String lang) {
    _settings.language = lang;
    _prefs.setString('language', lang);
    notifyListeners();
  }

  /// Đặt lại tất cả cài đặt về mặc định
  void resetSettings() {
    _settings = SettingsModel();
    _prefs.remove('temperatureUnit');
    _prefs.remove('windSpeedUnit');
    _prefs.remove('theme');
    _prefs.remove('timeFormat');
    _prefs.remove('language');
    notifyListeners();
  }
}