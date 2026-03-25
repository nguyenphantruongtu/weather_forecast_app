import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_config_model.dart';
import 'weather_api_service.dart';

class NotificationService {
  static const String _configKey = 'notification_config';
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final WeatherApiService _weatherService = WeatherApiService(
    dio: Dio(),
    apiKey: 'dummy_key',
    baseUrl: 'https://api.openweathermap.org/data/2.5',
  );

  static const _channelId = 'weather_forecast_channel';
  static const _channelName = 'Weather Forecast Updates';
  static const _channelDescription = 'Hourly and daily weather notifications';

  static const int _idHourly = 1001;
  static const int _idMorning = 1002;
  static const int _idEvening = 1003;
  static const int _idWeekend = 1004;
  static const int _idAlerts = 1005;
  static const int _idTest = 1006;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      final localZoneName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(localZoneName));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle taps if needed
      },
    );

    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> loadAndScheduleFromSaved() async {
    final config = await loadConfig();
    await scheduleNotifications(config);
  }

  Future<NotificationConfigModel> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_configKey);
      if (jsonStr != null) {
        return NotificationConfigModel.fromJson(jsonDecode(jsonStr));
      }
    } catch (e) {
      // Return default config on error
    }
    return NotificationConfigModel();
  }

  Future<void> saveConfig(NotificationConfigModel config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, jsonEncode(config.toJson()));
    await scheduleNotifications(config);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    tz.TZDateTime scheduled = _nextInstanceOfTime(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<String> _buildBodyForForecast(String city) async {
    try {
      final weather = await _weatherService.getCurrentWeather(city);
      return '${weather.location}: ${weather.temperature.toStringAsFixed(1)}°C, ${weather.description}. Open app for details.';
    } catch (_) {
      return 'Weather is updated. Open the app for latest info.';
    }
  }

  Future<void> scheduleNotifications(
    NotificationConfigModel config, {
    String city = 'Hanoi',
  }) async {
    await cancelAllNotifications();

    if (!config.pushNotificationsEnabled) return;

    try {
      if (config.hourlyForecastEnabled) {
        await _plugin.periodicallyShow(
          _idHourly,
          'Hourly Weather Update',
          'Hourly weather details are ready. Tap to view.',
          RepeatInterval.hourly,
          _notificationDetails(),
          androidAllowWhileIdle: true,
        );
      }

      if (config.morningForecastEnabled) {
        final body = await _buildBodyForForecast(city);
        await _plugin.zonedSchedule(
          _idMorning,
          'Morning Forecast',
          body,
          _nextInstanceOfTime(
            config.morningForecastTime.hour,
            config.morningForecastTime.minute,
          ),
          _notificationDetails(),
          androidAllowWhileIdle: true,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      if (config.eveningForecastEnabled) {
        final body = await _buildBodyForForecast(city);
        await _plugin.zonedSchedule(
          _idEvening,
          'Evening Forecast',
          body,
          _nextInstanceOfTime(
            config.eveningForecastTime.hour,
            config.eveningForecastTime.minute,
          ),
          _notificationDetails(),
          androidAllowWhileIdle: true,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      if (config.weekendSummaryEnabled) {
        final body =
            'Weekend summary is ready. Have a safe and enjoyable weekend!';
        await _plugin.zonedSchedule(
          _idWeekend,
          'Weekend Forecast Summary',
          body,
          _nextInstanceOfWeekday(DateTime.friday, 18, 0),
          _notificationDetails(),
          androidAllowWhileIdle: true,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }

      if (config.severeWeatherWarningsEnabled ||
          config.weatherAdvisoriesEnabled) {
        await _plugin.zonedSchedule(
          _idAlerts,
          'Weather Alerts Check',
          'Check for severe weather alerts and advisories in your area.',
          _nextInstanceOfTime(8, 0),
          _notificationDetails(),
          androidAllowWhileIdle: true,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } catch (e, st) {}
  }

  NotificationDetails _notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const iOSDetails = DarwinNotificationDetails();

    return const NotificationDetails(android: androidDetails, iOS: iOSDetails);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<void> showTestNotification() async {
    await _plugin.show(
      0,
      'Test Notification',
      'This is a test weather notification to verify functionality.',
      _notificationDetails(),
    );
  }

  Future<void> scheduleTestNotification({int seconds = 5}) async {
    final scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(seconds: seconds));
    await _plugin.zonedSchedule(
      _idTest,
      'Scheduled Test Notification',
      'Notification will appear after $seconds seconds.',
      scheduledTime,
      _notificationDetails(),
      androidAllowWhileIdle: true,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: null,
    );
  }
}
