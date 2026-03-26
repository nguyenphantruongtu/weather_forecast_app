import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/settings_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/unit_converter.dart';
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
    if (widget.city != null) {
      _currentCity = widget.city!;
    } else {
      // Get current selected city from LocationProvider
      final locationProv = context.read<LocationProvider>();
      _currentCity = locationProv.selectedCity?.name ?? 'Hanoi';
    }
    _loadData();
  }

  void _loadData() {
    final weatherProvider = context.read<WeatherProvider>();
    weatherProvider.fetchDailyForecast(_currentCity);
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
          AppStrings.tr(
            languageCode,
            en: 'Daily Forecast (7-10 days)',
            vi: 'Du bao hang ngay (7-10 ngay)',
          ),
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
            return _buildErrorState(
              context,
              weatherProvider.error!,
              languageCode,
            );
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
                    AppStrings.tr(
                      languageCode,
                      en: 'No forecast data available',
                      vi: 'Khong co du lieu du bao',
                    ),
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
                        '${AppStrings.tr(languageCode, en: 'Forecast for', vi: 'Du bao cho')} $_currentCity',
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
                              label: AppStrings.tr(
                                languageCode,
                                en: 'Chart',
                                vi: 'Bieu do',
                              ),
                              isSelected: _selectedViewIndex == 0,
                              onPressed: () =>
                                  setState(() => _selectedViewIndex = 0),
                            ),
                            const SizedBox(width: 8),
                            _ViewModeButton(
                              label: AppStrings.tr(
                                languageCode,
                                en: 'Cards',
                                vi: 'The',
                              ),
                              isSelected: _selectedViewIndex == 1,
                              onPressed: () =>
                                  setState(() => _selectedViewIndex = 1),
                            ),
                            const SizedBox(width: 8),
                            _ViewModeButton(
                              label: AppStrings.tr(
                                languageCode,
                                en: 'List',
                                vi: 'Danh sach',
                              ),
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
                  child: DailyForecastChart(
                    forecasts: forecasts,
                    temperatureUnit: settings.temperatureUnit,
                    languageCode: languageCode,
                  ),
                )
              else if (_selectedViewIndex == 1)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => DailyForecastCard(
                      forecast: forecasts[index],
                      dayNumber: index + 1,
                      temperatureUnit: settings.temperatureUnit,
                      windSpeedUnit: settings.windSpeedUnit,
                      languageCode: languageCode,
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
                      temperatureUnit: settings.temperatureUnit,
                      windSpeedUnit: settings.windSpeedUnit,
                      languageCode: languageCode,
                    ),
                    childCount: forecasts.length,
                  ),
                ),

              // Summary statistics
              SliverToBoxAdapter(
                child: _buildSummarySection(
                  forecasts,
                  settings.temperatureUnit,
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
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2431) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    String languageCode,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            AppStrings.tr(
              languageCode,
              en: 'Error loading forecast',
              vi: 'Loi tai du bao',
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
            label: Text(
              AppStrings.tr(languageCode, en: 'Retry', vi: 'Thu lai'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    List<dynamic> forecasts,
    TemperatureUnit temperatureUnit,
    String languageCode,
  ) {
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

    final displayAvg = _displayTemperature(avgTemp, temperatureUnit);
    final displayMax = _displayTemperature(maxTemp, temperatureUnit);
    final displayMin = _displayTemperature(minTemp, temperatureUnit);

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
            Text(
              AppStrings.tr(
                languageCode,
                en: '10-Day Summary',
                vi: 'Tong ket 10 ngay',
              ),
              style: const TextStyle(
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
                  label: AppStrings.tr(
                    languageCode,
                    en: 'Avg Temp',
                    vi: 'Nhiet do TB',
                  ),
                  value: '${displayAvg.toStringAsFixed(1)}°',
                ),
                _SummaryItem(
                  label: AppStrings.tr(
                    languageCode,
                    en: 'High',
                    vi: 'Cao nhat',
                  ),
                  value: '${displayMax.toStringAsFixed(1)}°',
                ),
                _SummaryItem(
                  label: AppStrings.tr(
                    languageCode,
                    en: 'Low',
                    vi: 'Thap nhat',
                  ),
                  value: '${displayMin.toStringAsFixed(1)}°',
                ),
                _SummaryItem(
                  label: AppStrings.tr(
                    languageCode,
                    en: 'Humidity',
                    vi: 'Do am',
                  ),
                  value: '${avgHumidity.toStringAsFixed(0)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _displayTemperature(double celsiusValue, TemperatureUnit unit) {
    if (unit == TemperatureUnit.fahrenheit) {
      return UnitConverter.celsiusToFahrenheit(celsiusValue);
    }
    return celsiusValue;
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
