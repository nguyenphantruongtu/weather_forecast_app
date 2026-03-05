import '../models/chart_data_model.dart';

class ChartDataProcessor {
  const ChartDataProcessor._();

  static double maxTemperatureValue(List<TemperaturePoint> points) {
    if (points.isEmpty) return 1;
    return points.map((e) => e.max).reduce((a, b) => a > b ? a : b) + 2;
  }

  static double minTemperatureValue(List<TemperaturePoint> points) {
    if (points.isEmpty) return -1;
    return points.map((e) => e.min).reduce((a, b) => a < b ? a : b) - 2;
  }

  static double maxPrecipitationValue(List<PrecipitationPoint> points) {
    if (points.isEmpty) return 1;
    return points.map((e) => e.amount).reduce((a, b) => a > b ? a : b) + 1;
  }
}
