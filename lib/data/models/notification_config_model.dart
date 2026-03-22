class NotificationConfigModel {
  bool pushNotificationsEnabled;
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
    this.morningForecastEnabled = true,
    TimeOfDayModel? morningForecastTime,
    this.eveningForecastEnabled = true,
    TimeOfDayModel? eveningForecastTime,
    this.weekendSummaryEnabled = true,
    this.severeWeatherWarningsEnabled = true,
    this.weatherAdvisoriesEnabled = true,
    List<String>? subscribedLocations,
    this.useCurrentLocation = true,
  })  : morningForecastTime = morningForecastTime ?? TimeOfDayModel(hour: 7, minute: 0),
        eveningForecastTime = eveningForecastTime ?? TimeOfDayModel(hour: 19, minute: 0),
        subscribedLocations = subscribedLocations ?? ['Hanoi', 'Da Nang'];

  Map<String, dynamic> toJson() => {
        'pushNotificationsEnabled': pushNotificationsEnabled,
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
    return NotificationConfigModel(
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      morningForecastEnabled: json['morningForecastEnabled'] ?? true,
      eveningForecastEnabled: json['eveningForecastEnabled'] ?? true,
      weekendSummaryEnabled: json['weekendSummaryEnabled'] ?? true,
      severeWeatherWarningsEnabled: json['severeWeatherWarningsEnabled'] ?? true,
      weatherAdvisoriesEnabled: json['weatherAdvisoriesEnabled'] ?? true,
      subscribedLocations: List<String>.from(json['subscribedLocations'] ?? ['Hanoi']),
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