import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/models/settings_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/unit_converter.dart';
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
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: onSurface),
        title: Text(
          AppStrings.tr(languageCode, en: 'Weather Details', vi: 'Chi tiet thoi tiet'),
          style: TextStyle(
            color: onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: Icon(Icons.refresh, color: onSurface),
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, _) {
          if (weatherProvider.isLoading) {
            return _buildLoadingState(context);
          }

          if (weatherProvider.error != null) {
            return _buildErrorState(weatherProvider.error!, languageCode);
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
                    AppStrings.tr(
                      languageCode,
                      en: 'No weather data available',
                      vi: 'Khong co du lieu thoi tiet',
                    ),
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Current weather card
              SliverToBoxAdapter(
                child: WeatherDetailsCard(
                  weather: weather,
                  temperatureUnit: settings.temperatureUnit,
                  timeFormat: settings.timeFormat,
                  languageCode: languageCode,
                ),
              ),

              // Atmospheric metrics
              SliverToBoxAdapter(
                child: AtmosphericMetricsGrid(
                  weather: weather,
                  temperatureUnit: settings.temperatureUnit,
                  languageCode: languageCode,
                ),
              ),

              // Wind details
              SliverToBoxAdapter(
                child: WindDetailsCard(
                  weather: weather,
                  windSpeedUnit: settings.windSpeedUnit,
                  languageCode: languageCode,
                ),
              ),

              // UV Index
              SliverToBoxAdapter(
                child: UVIndexChart(weather: weather, languageCode: languageCode),
              ),

              // Sun & Moon
              SliverToBoxAdapter(
                child: SunMoonDetailsCard(
                  weather: weather,
                  timeFormat: settings.timeFormat,
                  languageCode: languageCode,
                ),
              ),

              // Additional info
              SliverToBoxAdapter(
                child: _buildAdditionalInfo(
                  weather,
                  settings.temperatureUnit,
                  settings.timeFormat,
                  languageCode,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: isDark ? const Color(0xFF1E2431) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error, String languageCode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            AppStrings.tr(
              languageCode,
              en: 'Error loading weather details',
              vi: 'Loi tai chi tiet thoi tiet',
            ),
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
            label: Text(AppStrings.tr(languageCode, en: 'Retry', vi: 'Thu lai')),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(
    WeatherModel weather,
    TemperatureUnit temperatureUnit,
    TimeFormat timeFormat,
    String languageCode,
  ) {
    final displayTemp = _displayTemperature(weather.temperature, temperatureUnit);
    final displayFeelsLike = _displayTemperature(weather.feelsLike, temperatureUnit);
    final timePattern = timeFormat == TimeFormat.h24 ? 'yyyy-MM-dd HH:mm:ss' : 'yyyy-MM-dd h:mm:ss a';
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.tr(
                languageCode,
                en: 'Additional Information',
                vi: 'Thong tin bo sung',
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: AppStrings.tr(languageCode, en: 'Last Updated', vi: 'Cap nhat luc'),
              value: _formatDateTime(weather.lastUpdated, timePattern),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: AppStrings.tr(languageCode, en: 'Location', vi: 'Vi tri'), value: weather.location),
            const SizedBox(height: 12),
            _InfoRow(label: AppStrings.tr(languageCode, en: 'Description', vi: 'Mo ta'), value: weather.description),
            const SizedBox(height: 12),
            _InfoRow(
              label: AppStrings.tr(languageCode, en: 'Temperature', vi: 'Nhiet do'),
              value: '${displayTemp.toStringAsFixed(1)}°',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: AppStrings.tr(languageCode, en: 'Feels Like', vi: 'Cam giac nhu'),
              value: '${displayFeelsLike.toStringAsFixed(1)}°',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value, String pattern) {
    return value.toString().split('.')[0];
  }

  double _displayTemperature(double celsiusValue, TemperatureUnit unit) {
    if (unit == TemperatureUnit.fahrenheit) {
      return UnitConverter.celsiusToFahrenheit(celsiusValue);
    }
    return celsiusValue;
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
