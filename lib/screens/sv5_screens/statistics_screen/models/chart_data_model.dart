class TemperaturePoint {
  const TemperaturePoint({
    required this.x,
    required this.max,
    required this.avg,
    required this.min,
    required this.label,
  });

  final double x;
  final double max;
  final double avg;
  final double min;
  final String label;
}

class PrecipitationPoint {
  const PrecipitationPoint({
    required this.x,
    required this.amount,
    required this.label,
  });

  final double x;
  final double amount;
  final String label;
}

class WindRoseBucket {
  const WindRoseBucket({required this.directionLabel, required this.value});

  final String directionLabel;
  final double value;
}

class UvHeatmapItem {
  const UvHeatmapItem({required this.dateLabel, required this.uv});

  final String dateLabel;
  final double uv;
}
