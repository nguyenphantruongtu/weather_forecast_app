class NotificationConfigModel {
  bool pushNotificationsEnabled;
  bool hourlyForecastEnabled;
  bool morningForecastEnabled;
  TimeOfDayModel morningForecastTime;
  bool eveningForecastEnabled;
  TimeOfDayModel eveningForecastTime;
  bool weekendSummaryEnabled;
  bool severeWeatherWarningsEnabled;
  bool weatherAdvisoriesEnabled;
  List<String> subscribedLocations;
  bool useCurrentLocation;

  NotificationConfigModel({
    this.pushNotificationsEnabled = true,
    this.hourlyForecastEnabled = false,
    this.morningForecastEnabled = true,
    TimeOfDayModel? morningForecastTime,
    this.eveningForecastEnabled = true,
    TimeOfDayModel? eveningForecastTime,
    this.weekendSummaryEnabled = true,
    this.severeWeatherWarningsEnabled = true,
    this.weatherAdvisoriesEnabled = true,
    List<String>? subscribedLocations,
    this.useCurrentLocation = true,
  })  : morningForecastTime =
            morningForecastTime ?? const TimeOfDayModel(hour: 7, minute: 0),
        eveningForecastTime =
            eveningForecastTime ?? const TimeOfDayModel(hour: 19, minute: 0),
        subscribedLocations =
            subscribedLocations ?? ['Hanoi', 'Da Nang'];

  Map<String, dynamic> toJson() => {
        'pushNotificationsEnabled': pushNotificationsEnabled,
        'hourlyForecastEnabled': hourlyForecastEnabled,
        'morningForecastEnabled': morningForecastEnabled,
        'morningForecastTime': morningForecastTime.toJson(),
        'eveningForecastEnabled': eveningForecastEnabled,
        'eveningForecastTime': eveningForecastTime.toJson(),
        'weekendSummaryEnabled': weekendSummaryEnabled,
        'severeWeatherWarningsEnabled': severeWeatherWarningsEnabled,
        'weatherAdvisoriesEnabled': weatherAdvisoriesEnabled,
        'subscribedLocations': subscribedLocations,
        'useCurrentLocation': useCurrentLocation,
      };

  factory NotificationConfigModel.fromJson(Map<String, dynamic> json) {
    TimeOfDayModel parseTimeOfDay(dynamic map, TimeOfDayModel fallback) {
      if (map is Map<String, dynamic>) {
        final hour = map['hour'];
        final minute = map['minute'];
        if (hour is int && minute is int) {
          return TimeOfDayModel(hour: hour, minute: minute);
        }
      }
      return fallback;
    }

    return NotificationConfigModel(
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      hourlyForecastEnabled: json['hourlyForecastEnabled'] ?? false,
      morningForecastEnabled: json['morningForecastEnabled'] ?? true,
      morningForecastTime: parseTimeOfDay(
        json['morningForecastTime'],
        const TimeOfDayModel(hour: 7, minute: 0),
      ),
      eveningForecastEnabled: json['eveningForecastEnabled'] ?? true,
      eveningForecastTime: parseTimeOfDay(
        json['eveningForecastTime'],
        const TimeOfDayModel(hour: 19, minute: 0),
      ),
      weekendSummaryEnabled: json['weekendSummaryEnabled'] ?? true,
      severeWeatherWarningsEnabled:
          json['severeWeatherWarningsEnabled'] ?? true,
      weatherAdvisoriesEnabled: json['weatherAdvisoriesEnabled'] ?? true,
      subscribedLocations: List<String>.from(
        json['subscribedLocations'] ?? ['Hanoi', 'Da Nang'],
      ),
      useCurrentLocation: json['useCurrentLocation'] ?? true,
    );
  }
}

class TimeOfDayModel {
  final int hour;
  final int minute;

  const TimeOfDayModel({required this.hour, required this.minute});

  String get formatted {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};
}