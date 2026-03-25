import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:final_project/data/models/weather_model.dart';
import 'package:final_project/utils/app_strings.dart';

class UVIndexChart extends StatelessWidget {
  final WeatherModel weather;
  final String languageCode;

  const UVIndexChart({
    super.key,
    required this.weather,
    required this.languageCode,
  });

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
            Text(
              AppStrings.tr(languageCode, en: 'UV Index', vi: 'Chi so UV'),
              style: const TextStyle(
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
                                weather.uvIndex.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: uvColor,
                                ),
                              ),
                              Text(
                                AppStrings.tr(languageCode, en: 'UV Index', vi: 'Chi so UV'),
                                style: const TextStyle(
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
                      color: uvColor.withValues(alpha: 0.1),
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
        Text(
          AppStrings.tr(languageCode, en: 'UV Index Scale', vi: 'Thang do UV'),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _UVScaleItem(color: Colors.green, label: AppStrings.tr(languageCode, en: 'Low', vi: 'Thap'), range: '0-2'),
            _UVScaleItem(color: Colors.yellow, label: AppStrings.tr(languageCode, en: 'Moderate', vi: 'Vua'), range: '3-5'),
            _UVScaleItem(color: Colors.orange, label: AppStrings.tr(languageCode, en: 'High', vi: 'Cao'), range: '6-7'),
            _UVScaleItem(color: Colors.red, label: AppStrings.tr(languageCode, en: 'V. High', vi: 'Rat cao'), range: '8-10'),
            _UVScaleItem(color: Colors.purple, label: AppStrings.tr(languageCode, en: 'Extreme', vi: 'Cuc cao'), range: '11+'),
          ],
        ),
      ],
    );
  }

  String _getUVLevel(int index) {
    if (index < 3) return AppStrings.tr(languageCode, en: 'Low', vi: 'Thap');
    if (index < 6) return AppStrings.tr(languageCode, en: 'Moderate', vi: 'Vua');
    if (index < 8) return AppStrings.tr(languageCode, en: 'High', vi: 'Cao');
    if (index < 11) return AppStrings.tr(languageCode, en: 'Very High', vi: 'Rat cao');
    return AppStrings.tr(languageCode, en: 'Extreme', vi: 'Cuc cao');
  }

  Color _getUVColor(int index) {
    if (index < 3) return Colors.green;
    if (index < 6) return Colors.yellow.shade700;
    if (index < 8) return Colors.orange;
    if (index < 11) return Colors.red;
    return Colors.purple;
  }

  String _getUVAdvice(int index) {
    if (index < 3) {
      return AppStrings.tr(languageCode, en: 'No protection required', vi: 'Khong can bao ve');
    }
    if (index < 6) {
      return AppStrings.tr(languageCode, en: 'Wear sunscreen and a hat', vi: 'Nen boi kem chong nang va doi mu');
    }
    if (index < 8) {
      return AppStrings.tr(languageCode, en: 'Extra protection needed', vi: 'Can bao ve ky hon');
    }
    if (index < 11) {
      return AppStrings.tr(languageCode, en: 'Minimize time in sun', vi: 'Han che thoi gian duoi nang');
    }
    return AppStrings.tr(languageCode, en: 'Avoid sun exposure', vi: 'Nen tranh tiep xuc nang');
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
