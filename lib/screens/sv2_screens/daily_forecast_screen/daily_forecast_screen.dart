import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/weather_provider.dart';
import 'widgets/daily_forecast_card.dart';
import 'widgets/daily_forecast_chart.dart';
import 'widgets/daily_forecast_item.dart';

class DailyForecastScreen extends StatefulWidget {
  final String? city;

  const DailyForecastScreen({super.key, this.city});

  @override
  State<DailyForecastScreen> createState() => _DailyForecastScreenState();
}

class _DailyForecastScreenState extends State<DailyForecastScreen> {
  late String _currentCity;
  int _selectedViewIndex = 0; // 0: Chart, 1: Card, 2: List

  @override
  void initState() {
    super.initState();
    _currentCity = widget.city ?? 'Hanoi';
    _loadData();
  }

  void _loadData() {
    final weatherProvider = context.read<WeatherProvider>();
    weatherProvider.fetchDailyForecast(_currentCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Daily Forecast (7-10 days)',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.black87),
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, _) {
          if (weatherProvider.isLoading) {
            return _buildLoadingState();
          }

          if (weatherProvider.error != null) {
            return _buildErrorState(weatherProvider.error!);
          }

          final forecasts = weatherProvider.dailyForecast;
          if (forecasts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No forecast data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // View mode selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Forecast for $_currentCity',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _ViewModeButton(
                              label: 'Chart',
                              isSelected: _selectedViewIndex == 0,
                              onPressed: () =>
                                  setState(() => _selectedViewIndex = 0),
                            ),
                            const SizedBox(width: 8),
                            _ViewModeButton(
                              label: 'Cards',
                              isSelected: _selectedViewIndex == 1,
                              onPressed: () =>
                                  setState(() => _selectedViewIndex = 1),
                            ),
                            const SizedBox(width: 8),
                            _ViewModeButton(
                              label: 'List',
                              isSelected: _selectedViewIndex == 2,
                              onPressed: () =>
                                  setState(() => _selectedViewIndex = 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content based on selected view
              if (_selectedViewIndex == 0)
                SliverToBoxAdapter(
                  child: DailyForecastChart(forecasts: forecasts),
                )
              else if (_selectedViewIndex == 1)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => DailyForecastCard(
                      forecast: forecasts[index],
                      dayNumber: index + 1,
                    ),
                    childCount: forecasts.length,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => DailyForecastItem(
                      forecast: forecasts[index],
                      dayNumber: index + 1,
                    ),
                    childCount: forecasts.length,
                  ),
                ),

              // Summary statistics
              SliverToBoxAdapter(child: _buildSummarySection(forecasts)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error loading forecast',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(List<dynamic> forecasts) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    double avgTemp = 0;
    double maxTemp = forecasts[0].tempMax;
    double minTemp = forecasts[0].tempMin;
    double avgHumidity = 0;

    for (var forecast in forecasts) {
      avgTemp += forecast.temp;
      avgHumidity += forecast.humidity;
      if (forecast.tempMax > maxTemp) maxTemp = forecast.tempMax;
      if (forecast.tempMin < minTemp) minTemp = forecast.tempMin;
    }

    avgTemp /= forecasts.length;
    avgHumidity /= forecasts.length;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade500, Colors.blue.shade700],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '10-Day Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  label: 'Avg Temp',
                  value: '${avgTemp.toStringAsFixed(1)}°',
                ),
                _SummaryItem(
                  label: 'High',
                  value: '${maxTemp.toStringAsFixed(1)}°',
                ),
                _SummaryItem(
                  label: 'Low',
                  value: '${minTemp.toStringAsFixed(1)}°',
                ),
                _SummaryItem(
                  label: 'Humidity',
                  value: '${avgHumidity.toStringAsFixed(0)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ViewModeButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.shade600 : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.blue.shade600,
        side: BorderSide(color: Colors.blue.shade300, width: 1),
      ),
      child: Text(label),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
