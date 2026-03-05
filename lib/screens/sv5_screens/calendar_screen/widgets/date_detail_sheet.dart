import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/weather_day_model.dart';
import '../utils/temperature_gradient.dart';
import 'animated_weather_icon.dart';
import 'weather_metric_card.dart';

class DateDetailSheet extends StatelessWidget {
  const DateDetailSheet({
    super.key,
    required this.weather,
    required this.onSwipePrevious,
    required this.onSwipeNext,
  });

  final WeatherDayModel weather;
  final VoidCallback onSwipePrevious;
  final VoidCallback onSwipeNext;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx > 80) {
          onSwipePrevious();
        } else if (details.velocity.pixelsPerSecond.dx < -80) {
          onSwipeNext();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.20),
              Colors.white.withValues(alpha: 0.10),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.30),
            width: 1.2,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'weather-icon-${weather.dateKey}',
                    child: AnimatedWeatherIcon(
                      assetPath: weather.iconAssetPath,
                      size: 74,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEE, dd MMM yyyy').format(weather.date),
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: weather.tempMin,
                            end: weather.temp,
                          ),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return Text(
                              '${value.toStringAsFixed(1)}°C',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w300,
                              ),
                            );
                          },
                        ),
                        Text(
                          weather.condition,
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: _TempMiniChart(temps: weather.hourlyTemperatures),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  WeatherMetricCard(
                    icon: Icons.thermostat,
                    title: 'Feels Like',
                    value: '${weather.feelsLike.toStringAsFixed(1)}°C',
                  ),
                  WeatherMetricCard(
                    icon: Icons.water_drop,
                    title: 'Humidity',
                    value: '${weather.humidity}%',
                    progress: weather.humidity / 100,
                  ),
                  WeatherMetricCard(
                    icon: Icons.air,
                    title: 'Wind',
                    value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                  ),
                  WeatherMetricCard(
                    icon: Icons.wb_sunny_outlined,
                    title: 'UV Index',
                    value: weather.uvIndex.toStringAsFixed(1),
                    progress: (weather.uvIndex / 12).clamp(0.0, 1.0),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: WeatherMetricCard(
                      icon: Icons.umbrella,
                      title: 'Precipitation',
                      value:
                          '${(weather.precipitationProbability * 100).round()}%',
                      progress: weather.precipitationProbability,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 118,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.16),
                            Colors.white.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: _SunArcPainter(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${DateFormat('HH:mm').format(weather.sunrise)} / ${DateFormat('HH:mm').format(weather.sunset)}',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Sunrise / Sunset',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swipe_left, color: Colors.white60, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Swipe to browse days',
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.swipe_right, color: Colors.white60, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TempMiniChart extends StatelessWidget {
  const _TempMiniChart({required this.temps});

  final List<double> temps;

  @override
  Widget build(BuildContext context) {
    final data = temps.isEmpty ? <double>[0, 0] : temps;
    final maxY = data.reduce(math.max) + 2;
    final minY = data.reduce(math.min) - 2;
    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
              (i) => FlSpot(i.toDouble(), data[i]),
            ),
            isCurved: true,
            color: const Color(0xFF7FC8FF),
            barWidth: 2.6,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  TemperatureGradient.fromTemp(
                    data.first,
                  ).colors.first.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 280),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white70;
    final rect = Rect.fromLTWH(8, 14, size.width - 16, size.height - 38);
    canvas.drawArc(rect, math.pi, math.pi, false, paintArc);
    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.amberAccent;
    canvas.drawCircle(Offset(size.width / 2, 16), 4, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
