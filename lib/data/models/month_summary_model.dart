class MonthSummary {
  const MonthSummary({
    required this.avgTemp,
    required this.totalRainfall,
    required this.sunnyDays,
    required this.rainyDays,
    required this.dailyAvgTemps,
  });

  final double avgTemp;
  final double totalRainfall;
  final int sunnyDays;
  final int rainyDays;
  final List<double> dailyAvgTemps;
}
