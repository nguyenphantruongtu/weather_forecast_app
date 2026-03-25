import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/weather_provider.dart';
import '../../../utils/app_strings.dart';
import '../../OnboardingAndUserPreferencesScreens/settings_screen/settings_screen.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/weather_metrics_grid.dart';
import 'widgets/forecast_preview.dart';
import '../../NotiAndNewsScreens/noti_news_main_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCompare;
  const HomeScreen({super.key, this.onNavigateToCompare});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

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
    if (weatherProvider.currentWeather == null) {
      weatherProvider.fetchCurrentWeather('Hanoi');
      weatherProvider.fetchHourlyForecast('Hanoi');
    }
  }

  void _handleSearch(String city) {
    setState(() {
      _searchController.clear();
    });
    final weatherProvider = context.read<WeatherProvider>();
    weatherProvider.fetchCurrentWeather(city);
    weatherProvider.fetchHourlyForecast(city);
  }

    // THÊM: Hàm điều hướng sang NotiNewsMainScreen
  void _navigateToNotiNews() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NotiNewsMainScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceTextColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            pinned: true,
            title: Text(
              AppStrings.tr(languageCode, en: 'Weather Now', vi: 'Thời tiết hôm nay'),
              style: TextStyle(
                color: surfaceTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // THÊM: Nút điều hướng sang Alerts & News
              IconButton(
                onPressed: _navigateToNotiNews,
                icon: Icon(Icons.notifications_outlined, color: surfaceTextColor),
                tooltip: 'Alerts & News',
              ),
              IconButton(
                onPressed: _loadWeatherData,
                icon: Icon(Icons.refresh, color: surfaceTextColor),
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
                  hintText: AppStrings.tr(
                    languageCode,
                    en: 'Search city...',
                    vi: 'Tìm thành phố...',
                  ),
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
                  fillColor: isDark ? const Color(0xFF1E2533) : Colors.white,
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
                            '${AppStrings.tr(languageCode, en: 'Error', vi: 'Lỗi')}: ${weatherProvider.error}',
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
                        CurrentWeatherCard(
                          weather: currentWeather,
                          onCompareTap: widget.onNavigateToCompare,
                          onSettingsTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                          temperatureUnit: settings.temperatureUnit,
                          timeFormat: settings.timeFormat,
                          languageCode: languageCode,
                        ),
                        const SizedBox(height: 24),

                        // Weather Metrics Grid
                        Text(
                          AppStrings.tr(languageCode, en: 'Details', vi: 'Chi tiết'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        WeatherMetricsGrid(
                          weather: currentWeather,
                          temperatureUnit: settings.temperatureUnit,
                          windSpeedUnit: settings.windSpeedUnit,
                        ),
                        const SizedBox(height: 24),

                        // THÊM: Banner điều hướng nhanh sang News & Alerts
                        _buildNotiNewsBanner(),
                        const SizedBox(height: 24),

                        // Hourly Forecast Preview
                        ForecastPreview(
                          hourlyForecast: weatherProvider.hourlyForecast,
                          city: currentWeather.location.split(',').first.trim(),
                          temperatureUnit: settings.temperatureUnit,
                          timeFormat: settings.timeFormat,
                          languageCode: languageCode,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showWeatherMenu();
        },
        tooltip: 'More options',
        backgroundColor: Colors.blue.shade500,
        child: const Icon(Icons.cloud),
      ),
    );
  }

    // THÊM: Banner gọn điều hướng sang News & Alerts
  Widget _buildNotiNewsBanner() {
    return GestureDetector(
      onTap: _navigateToNotiNews,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B7AEF), Color(0xFF8E9BF5)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B7AEF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active_outlined,
                color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weather Alerts & News',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Check active alerts and latest weather news',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  void _showWeatherMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'More Weather Options',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            // Menu Items
            ListTile(
              leading: Icon(Icons.schedule, color: Colors.teal.shade500),
              title: const Text('Hourly Forecast'),
              subtitle: const Text('Next 24 hours'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/hourly-forecast');
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month, color: Colors.blue.shade500),
              title: const Text('Daily Forecast'),
              subtitle: const Text('7-10 days ahead'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/daily-forecast');
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.indigo.shade500),
              title: const Text('Weather Details'),
              subtitle: const Text('Detailed weather info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/weather-details');
              },
            ),
            // THÊM: Menu item điều hướng sang Alerts & News
            ListTile(
              leading: Icon(Icons.notifications_outlined,
                  color: const Color(0xFF6B7AEF)),
              title: const Text('Alerts & News'),
              subtitle: const Text('Weather alerts and latest news'),
              onTap: () {
                Navigator.pop(context);
                _navigateToNotiNews();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
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
