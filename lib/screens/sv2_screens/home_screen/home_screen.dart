import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/weather_provider.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/weather_metrics_grid.dart';
import 'widgets/forecast_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentCity = 'Hanoi';

  @override
  void initState() {
    super.initState();
    // Defer loading data after frame is built to avoid "setState during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeatherData();
    });
  }

  void _loadWeatherData() {
    final weatherProvider = context.read<WeatherProvider>();
    weatherProvider.fetchCurrentWeather(_currentCity);
    weatherProvider.fetchHourlyForecast(_currentCity);
  }

  void _handleSearch(String city) {
    setState(() {
      _currentCity = city;
      _searchController.clear();
    });
    _loadWeatherData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            pinned: true,
            title: const Text(
              'Weather Now',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _loadWeatherData,
                icon: const Icon(Icons.refresh, color: Colors.black87),
              ),
            ],
          ),
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: _handleSearch,
              ),
            ),
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Consumer<WeatherProvider>(
                builder: (context, weatherProvider, _) {
                  if (weatherProvider.isLoading) {
                    return _buildLoadingShimmer();
                  }

                  if (weatherProvider.error != null) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${weatherProvider.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade300),
                          ),
                        ],
                      ),
                    );
                  }

                  if (weatherProvider.currentWeather == null) {
                    return const SizedBox.shrink();
                  }

                  final currentWeather = weatherProvider.currentWeather!;

                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Weather Card
                        CurrentWeatherCard(weather: currentWeather),
                        const SizedBox(height: 24),

                        // Weather Metrics Grid
                        const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        WeatherMetricsGrid(weather: currentWeather),
                        const SizedBox(height: 24),

                        // Hourly Forecast Preview
                        ForecastPreview(
                          hourlyForecast: weatherProvider.hourlyForecast,
                          city: _currentCity,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather Card Shimmer
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 24),

          // Metrics Grid Shimmer
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: List.generate(
              6,
              (index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
