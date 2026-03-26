import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/weather_provider.dart';
import '../../../utils/app_strings.dart';
import '../../OnboardingAndUserPreferencesScreens/settings_screen/settings_screen.dart';
import '../../NotiAndNewsScreens/noti_news_main_screen.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/weather_metrics_grid.dart';
import 'widgets/forecast_preview.dart';

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

  Future<void> _handleSearch(String city) async {
    setState(() {
      _searchController.clear();
    });

    if (city.trim().isEmpty) return;

    final weatherProvider = context.read<WeatherProvider>();

    // Fetch weather using city name - WeatherApiService will handle geocoding
    // and return proper location name
    await weatherProvider.fetchCurrentWeather(city);
  }

  void _navigateToNotiNews() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NotiNewsMainScreen()));
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
          SliverAppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            pinned: true,
            title: Text(
              AppStrings.tr(
                languageCode,
                en: 'Weather Now',
                vi: 'Th\u1eddi ti\u1ebft h\u00f4m nay',
              ),
              style: TextStyle(
                color: surfaceTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _navigateToNotiNews,
                icon: Icon(
                  Icons.notifications_outlined,
                  color: surfaceTextColor,
                ),
                tooltip: AppStrings.tr(
                  languageCode,
                  en: 'Alerts & News',
                  vi: 'C\u1ea3nh b\u00e1o & Tin t\u1ee9c',
                ),
              ),
              IconButton(
                onPressed: _loadWeatherData,
                icon: Icon(Icons.refresh, color: surfaceTextColor),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.tr(
                    languageCode,
                    en: 'Search city...',
                    vi: 'T\u00ecm th\u00e0nh ph\u1ed1...',
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
                onChanged: (_) => setState(() {}),
                onSubmitted: _handleSearch,
              ),
            ),
          ),
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
                            '${AppStrings.tr(languageCode, en: 'Error', vi: 'L\u1ed7i')}: ${weatherProvider.error}',
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
                        Text(
                          AppStrings.tr(
                            languageCode,
                            en: 'Details',
                            vi: 'Chi ti\u1ebft',
                          ),
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
                          languageCode: languageCode,
                        ),
                        const SizedBox(height: 24),
                        _buildNotiNewsBanner(languageCode),
                        const SizedBox(height: 24),
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
        onPressed: _showWeatherMenu,
        tooltip: AppStrings.tr(
          languageCode,
          en: 'More options',
          vi: 'Th\u00eam t\u00f9y ch\u1ecdn',
        ),
        backgroundColor: Colors.blue.shade500,
        child: const Icon(Icons.cloud),
      ),
    );
  }

  Widget _buildNotiNewsBanner(String languageCode) {
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
              color: const Color(0xFF6B7AEF).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr(
                      languageCode,
                      en: 'Weather Alerts & News',
                      vi: 'C\u1ea3nh b\u00e1o & Tin t\u1ee9c',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.tr(
                      languageCode,
                      en: 'Check active alerts and latest weather news',
                      vi: 'Xem c\u1ea3nh b\u00e1o \u0111ang ho\u1ea1t \u0111\u1ed9ng v\u00e0 tin th\u1eddi ti\u1ebft m\u1edbi nh\u1ea5t',
                    ),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showWeatherMenu() {
    final languageCode = context.read<SettingsProvider>().settings.language;
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
                  AppStrings.tr(
                    languageCode,
                    en: 'More Weather Options',
                    vi: 'T\u00f9y ch\u1ecdn th\u1eddi ti\u1ebft',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: Colors.teal.shade500),
              title: Text(
                AppStrings.tr(
                  languageCode,
                  en: 'Hourly Forecast',
                  vi: 'D\u1ef1 b\u00e1o theo gi\u1edd',
                ),
              ),
              subtitle: Text(
                AppStrings.tr(
                  languageCode,
                  en: 'Next 24 hours',
                  vi: '24 gi\u1edd t\u1edbi',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/hourly-forecast');
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month, color: Colors.blue.shade500),
              title: Text(
                AppStrings.tr(
                  languageCode,
                  en: 'Daily Forecast',
                  vi: 'D\u1ef1 b\u00e1o h\u1eb1ng ng\u00e0y',
                ),
              ),
              subtitle: Text(
                AppStrings.tr(
                  languageCode,
                  en: '7-10 days ahead',
                  vi: '7-10 ng\u00e0y t\u1edbi',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/daily-forecast');
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.indigo.shade500),
              title: Text(
                AppStrings.tr(
                  languageCode,
                  en: 'Weather Details',
                  vi: 'Chi ti\u1ebft th\u1eddi ti\u1ebft',
                ),
              ),
              subtitle: Text(
                AppStrings.tr(
                  languageCode,
                  en: 'Detailed weather info',
                  vi: 'Th\u00f4ng tin th\u1eddi ti\u1ebft chi ti\u1ebft',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/weather-details');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF6B7AEF),
              ),
              title: Text(
                AppStrings.tr(
                  languageCode,
                  en: 'Alerts & News',
                  vi: 'C\u1ea3nh b\u00e1o & Tin t\u1ee9c',
                ),
              ),
              subtitle: Text(
                AppStrings.tr(
                  languageCode,
                  en: 'Weather alerts and latest news',
                  vi: 'C\u1ea3nh b\u00e1o th\u1eddi ti\u1ebft v\u00e0 tin t\u1ee9c m\u1edbi nh\u1ea5t',
                ),
              ),
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
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 24),
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
