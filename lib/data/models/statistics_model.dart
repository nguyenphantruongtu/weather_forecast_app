class WeatherStatistics {
  const WeatherStatistics({
    required this.period,
    required this.avgTemp,
    required this.maxTemp,
    required this.maxTempDate,
    required this.minTemp,
    required this.minTempDate,
    required this.tempTrend,
    required this.comparisonDiff,
    required this.comparisonUp,
  });

  final String period;
  final double avgTemp;
  final double maxTemp;
  final DateTime maxTempDate;
  final double minTemp;
  final DateTime minTempDate;
  final List<TempDataPoint> tempTrend;
  final double comparisonDiff;
  final bool comparisonUp;
}

class TempDataPoint {
  const TempDataPoint({
    required this.date,
    required this.maxTemp,
    required this.avgTemp,
    required this.minTemp,
  });

  final DateTime date;
  final double maxTemp;
  final double avgTemp;
  final double minTemp;
}
