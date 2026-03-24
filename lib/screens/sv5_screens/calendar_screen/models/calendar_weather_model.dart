import 'weather_day_model.dart';

class CalendarWeatherSummary {
  const CalendarWeatherSummary({
    required this.averageTemp,
    required this.rainyDays,
    required this.hottestDay,
    required this.coldestDay,
  });

  final double averageTemp;
  final int rainyDays;
  final WeatherDayModel? hottestDay;
  final WeatherDayModel? coldestDay;

  static CalendarWeatherSummary fromDays(List<WeatherDayModel> days) {
    if (days.isEmpty) {
      return const CalendarWeatherSummary(
        averageTemp: 0,
        rainyDays: 0,
        hottestDay: null,
        coldestDay: null,
      );
    }

    final avg = days.fold<double>(0, (sum, d) => sum + d.temp) / days.length;
    final rainy = days.where((d) => d.precipitationProbability > 0.2).length;

    final hottest = days.reduce((a, b) => a.tempMax >= b.tempMax ? a : b);
    final coldest = days.reduce((a, b) => a.tempMin <= b.tempMin ? a : b);

    return CalendarWeatherSummary(
      averageTemp: avg,
      rainyDays: rainy,
      hottestDay: hottest,
      coldestDay: coldest,
    );
  }
}
