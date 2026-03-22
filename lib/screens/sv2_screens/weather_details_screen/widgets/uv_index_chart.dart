import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:final_project/data/models/weather_model.dart';

class UVIndexChart extends StatelessWidget {
  final WeatherModel weather;

  const UVIndexChart({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final uvIndex = weather.uvIndex.toInt();
    final uvLevel = _getUVLevel(uvIndex);
    final uvColor = _getUVColor(uvIndex);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'UV Index',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: uvIndex.toDouble(),
                                  color: uvColor,
                                  radius: 40,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: (11 - uvIndex).toDouble(),
                                  color: Colors.grey.shade300,
                                  radius: 40,
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${weather.uvIndex.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: uvColor,
                                ),
                              ),
                              const Text(
                                'UV Index',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: uvColor.withOpacity(0.1),
                      border: Border.all(color: uvColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      uvLevel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: uvColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getUVAdvice(uvIndex),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildUVScale(),
          ],
        ),
      ),
    );
  }

  Widget _buildUVScale() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'UV Index Scale',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _UVScaleItem(color: Colors.green, label: 'Low', range: '0-2'),
            _UVScaleItem(color: Colors.yellow, label: 'Moderate', range: '3-5'),
            _UVScaleItem(color: Colors.orange, label: 'High', range: '6-7'),
            _UVScaleItem(color: Colors.red, label: 'V. High', range: '8-10'),
            _UVScaleItem(color: Colors.purple, label: 'Extreme', range: '11+'),
          ],
        ),
      ],
    );
  }

  String _getUVLevel(int index) {
    if (index < 3) return 'Low';
    if (index < 6) return 'Moderate';
    if (index < 8) return 'High';
    if (index < 11) return 'Very High';
    return 'Extreme';
  }

  Color _getUVColor(int index) {
    if (index < 3) return Colors.green;
    if (index < 6) return Colors.yellow.shade700;
    if (index < 8) return Colors.orange;
    if (index < 11) return Colors.red;
    return Colors.purple;
  }

  String _getUVAdvice(int index) {
    if (index < 3) return 'No protection required';
    if (index < 6) return 'Wear sunscreen and a hat';
    if (index < 8) return 'Extra protection needed';
    if (index < 11) return 'Minimize time in sun';
    return 'Avoid sun exposure';
  }
}

class _UVScaleItem extends StatelessWidget {
  final Color color;
  final String label;
  final String range;

  const _UVScaleItem({
    required this.color,
    required this.label,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            range,
            style: const TextStyle(fontSize: 8, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
