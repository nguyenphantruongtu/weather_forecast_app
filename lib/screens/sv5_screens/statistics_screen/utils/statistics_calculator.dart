import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import '../../calendar_screen/models/weather_day_model.dart';
import '../models/chart_data_model.dart';
import '../models/weather_statistics_model.dart';

class StatisticsCalculator {
  const StatisticsCalculator._();

  static WeatherStatisticsModel build(List<WeatherDayModel> data) {
    if (data.isEmpty) {
      return const WeatherStatisticsModel(
        avgTemp: 0,
        maxTemp: 0,
        minTemp: 0,
        rainyDays: 0,
        avgHumidity: 0,
        avgWindSpeed: 0,
        dominantCondition: '-',
        maxDateLabel: '-',
        minDateLabel: '-',
        temperatureTrend: <TemperaturePoint>[],
        precipitationTrend: <PrecipitationPoint>[],
        windRoseData: <WindRoseBucket>[],
        uvHeatmapData: <UvHeatmapItem>[],
      );
    }

    final sorted = [...data]..sort((a, b) => a.date.compareTo(b.date));
    final avgTemp =
        sorted.fold<double>(0, (p, e) => p + e.temp) / sorted.length;
    final avgHumidity =
        sorted.fold<double>(0, (p, e) => p + e.humidity) / sorted.length;
    final avgWind =
        sorted.fold<double>(0, (p, e) => p + e.windSpeed) / sorted.length;
    final rainyDays = sorted
        .where((e) => e.precipitationProbability > 0.2)
        .length;

    final maxDay = sorted.reduce((a, b) => a.tempMax >= b.tempMax ? a : b);
    final minDay = sorted.reduce((a, b) => a.tempMin <= b.tempMin ? a : b);

    final groupedCondition =
        sorted.groupListsBy((e) => e.condition).entries.toList()
          ..sort((a, b) => b.value.length.compareTo(a.value.length));
    final dominantCondition = groupedCondition.first.key;

    final tempTrend = <TemperaturePoint>[];
    final precipitation = <PrecipitationPoint>[];
    final uvHeatmap = <UvHeatmapItem>[];

    for (var i = 0; i < sorted.length; i++) {
      final item = sorted[i];
      tempTrend.add(
        TemperaturePoint(
          x: i.toDouble(),
          max: item.tempMax,
          avg: item.temp,
          min: item.tempMin,
          label: DateFormat('MM/dd').format(item.date),
        ),
      );
      precipitation.add(
        PrecipitationPoint(
          x: i.toDouble(),
          amount: item.precipitationAmount,
          label: DateFormat('dd').format(item.date),
        ),
      );
      uvHeatmap.add(
        UvHeatmapItem(
          dateLabel: DateFormat('dd/MM').format(item.date),
          uv: item.uvIndex,
        ),
      );
    }

    return WeatherStatisticsModel(
      avgTemp: avgTemp,
      maxTemp: maxDay.tempMax,
      minTemp: minDay.tempMin,
      rainyDays: rainyDays,
      avgHumidity: avgHumidity,
      avgWindSpeed: avgWind,
      dominantCondition: dominantCondition,
      maxDateLabel: DateFormat('dd MMM').format(maxDay.date),
      minDateLabel: DateFormat('dd MMM').format(minDay.date),
      temperatureTrend: tempTrend,
      precipitationTrend: precipitation,
      windRoseData: _buildWindRose(sorted),
      uvHeatmapData: uvHeatmap,
    );
  }

  static List<WindRoseBucket> _buildWindRose(List<WeatherDayModel> days) {
    final counts = <String, int>{
      'N': 0,
      'NE': 0,
      'E': 0,
      'SE': 0,
      'S': 0,
      'SW': 0,
      'W': 0,
      'NW': 0,
    };
    for (final day in days) {
      final degree = day.windDeg;
      if (degree >= 337 || degree < 22) {
        counts['N'] = counts['N']! + 1;
      } else if (degree < 67) {
        counts['NE'] = counts['NE']! + 1;
      } else if (degree < 112) {
        counts['E'] = counts['E']! + 1;
      } else if (degree < 157) {
        counts['SE'] = counts['SE']! + 1;
      } else if (degree < 202) {
        counts['S'] = counts['S']! + 1;
      } else if (degree < 247) {
        counts['SW'] = counts['SW']! + 1;
      } else if (degree < 292) {
        counts['W'] = counts['W']! + 1;
      } else {
        counts['NW'] = counts['NW']! + 1;
      }
    }
    return counts.entries
        .map(
          (e) =>
              WindRoseBucket(directionLabel: e.key, value: e.value.toDouble()),
        )
        .toList();
  }
}
