import 'package:flutter/foundation.dart';
import '../data/models/notification_config_model.dart';
import '../data/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;
  late NotificationConfigModel _config;
  bool _isLoading = false;

  NotificationProvider({NotificationService? service})
    : _service = service ?? NotificationService() {
    _config = NotificationConfigModel();
    _initialize();
  }

  NotificationConfigModel get config => _config;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    await _service.initialize();
    await _loadConfig();
  }

  Future<void> _loadConfig() async {
    _isLoading = true;
    notifyListeners();

    try {
      _config = await _service.loadConfig();
      await _service.scheduleNotifications(_config);
    } catch (e, st) {
      debugPrint('NotificationProvider._loadConfig error: $e\n$st');
      // Nếu xảy ra lỗi schedule, vẫn tiếp tục khởi động app.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePushNotifications(bool value) async {
    _config.pushNotificationsEnabled = value;
    await _save();
  }

  Future<void> toggleHourlyForecast(bool value) async {
    _config.hourlyForecastEnabled = value;
    await _save();
  }

  Future<void> toggleMorningForecast(bool value) async {
    _config.morningForecastEnabled = value;
    await _save();
  }

  Future<void> toggleEveningForecast(bool value) async {
    _config.eveningForecastEnabled = value;
    await _save();
  }

  Future<void> toggleWeekendSummary(bool value) async {
    _config.weekendSummaryEnabled = value;
    await _save();
  }

  Future<void> toggleSevereWeatherWarnings(bool value) async {
    _config.severeWeatherWarningsEnabled = value;
    await _save();
  }

  Future<void> toggleWeatherAdvisories(bool value) async {
    _config.weatherAdvisoriesEnabled = value;
    await _save();
  }

  Future<void> toggleCurrentLocation(bool value) async {
    _config.useCurrentLocation = value;
    await _save();
  }

  Future<void> toggleLocation(String location, bool selected) async {
    if (selected) {
      if (!_config.subscribedLocations.contains(location)) {
        _config.subscribedLocations.add(location);
      }
    } else {
      _config.subscribedLocations.remove(location);
    }
    await _save();
  }

  Future<void> updateForecastTime({
    required bool isMorning,
    required TimeOfDayModel newTime,
  }) async {
    if (isMorning) {
      _config.morningForecastTime = newTime;
    } else {
      _config.eveningForecastTime = newTime;
    }
    await _save();
  }

  Future<void> sendTestNotification() async {
    await _service.showTestNotification();
  }

  Future<void> scheduleTestNotification({int seconds = 5}) async {
    await _service.scheduleTestNotification(seconds: seconds);
  }

  Future<void> _save() async {
    await _service.saveConfig(_config);
    await _service.scheduleNotifications(_config);
    notifyListeners();
  }
}
