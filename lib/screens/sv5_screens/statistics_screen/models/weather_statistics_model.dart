import 'chart_data_model.dart';

class WeatherStatisticsModel {
  const WeatherStatisticsModel({
    required this.avgTemp,
    required this.maxTemp,
    required this.minTemp,
    required this.rainyDays,
    required this.avgHumidity,
    required this.avgWindSpeed,
    required this.dominantCondition,
    required this.maxDateLabel,
    required this.minDateLabel,
    required this.temperatureTrend,
    required this.precipitationTrend,
    required this.windRoseData,
    required this.uvHeatmapData,
  });

  final double avgTemp;
  final double maxTemp;
  final double minTemp;
  final int rainyDays;
  final double avgHumidity;
  final double avgWindSpeed;
  final String dominantCondition;
  final String maxDateLabel;
  final String minDateLabel;
  final List<TemperaturePoint> temperatureTrend;
  final List<PrecipitationPoint> precipitationTrend;
  final List<WindRoseBucket> windRoseData;
  final List<UvHeatmapItem> uvHeatmapData;
}
