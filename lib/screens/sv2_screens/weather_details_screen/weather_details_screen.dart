import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/weather_provider.dart';
import 'widgets/weather_details_card.dart';
import 'widgets/atmospheric_metrics_grid.dart';
import 'widgets/wind_details_card.dart';
import 'widgets/sun_moon_details_card.dart';
import 'widgets/uv_index_chart.dart';

class WeatherDetailsScreen extends StatefulWidget {
  final String? city;

  const WeatherDetailsScreen({super.key, this.city});

  @override
  State<WeatherDetailsScreen> createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends State<WeatherDetailsScreen> {
  late String _currentCity;

  @override
  void initState() {
    super.initState();
    _currentCity = widget.city ?? 'Hanoi';
    _loadData();
  }

  void _loadData() {
    final weatherProvider = context.read<WeatherProvider>();
    weatherProvider.fetchCurrentWeather(_currentCity);
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
          'Weather Details',
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

          final weather = weatherProvider.currentWeather;
          if (weather == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No weather data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Current weather card
              SliverToBoxAdapter(child: WeatherDetailsCard(weather: weather)),

              // Atmospheric metrics
              SliverToBoxAdapter(
                child: AtmosphericMetricsGrid(weather: weather),
              ),

              // Wind details
              SliverToBoxAdapter(child: WindDetailsCard(weather: weather)),

              // UV Index
              SliverToBoxAdapter(child: UVIndexChart(weather: weather)),

              // Sun & Moon
              SliverToBoxAdapter(child: SunMoonDetailsCard(weather: weather)),

              // Additional info
              SliverToBoxAdapter(child: _buildAdditionalInfo(weather)),
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
            height: 150,
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
            'Error loading weather details',
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

  Widget _buildAdditionalInfo(weather) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Last Updated',
              value: weather.lastUpdated.toString().split('.')[0],
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Location', value: weather.location),
            const SizedBox(height: 12),
            _InfoRow(label: 'Description', value: weather.description),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Temperature',
              value: '${weather.temperature.toStringAsFixed(1)}° C',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Feels Like',
              value: '${weather.feelsLike.toStringAsFixed(1)}° C',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
