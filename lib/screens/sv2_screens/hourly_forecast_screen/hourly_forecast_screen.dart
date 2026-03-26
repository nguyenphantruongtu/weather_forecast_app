import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/settings_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../utils/app_strings.dart';
import '../../../providers/weather_provider.dart';
import '../../../data/models/forecast_model.dart';
import '../../../utils/unit_converter.dart';
import 'widgets/hourly_chart.dart';
import 'widgets/hourly_item.dart';

class HourlyForecastScreen extends StatefulWidget {
  final String? city;

  const HourlyForecastScreen({super.key, this.city});

  @override
  State<HourlyForecastScreen> createState() => _HourlyForecastScreenState();
}

class _HourlyForecastScreenState extends State<HourlyForecastScreen> {
  int _selectedIndex = 0;
  late String _currentCity;

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
    weatherProvider.fetchHourlyForecast(_currentCity);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          AppStrings.tr(
            languageCode,
            en: 'Hourly Forecast',
            vi: 'Dự báo theo giờ',
          ),
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
            return _buildLoadingShimmer();
          }

          if (weatherProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text(
                      AppStrings.tr(languageCode, en: 'Retry', vi: 'Thử lại'),
                    ),
                  ),
                ],
              ),
            );
          }

          if (weatherProvider.hourlyForecast.isEmpty) {
            return Center(
              child: Text(
                AppStrings.tr(
                  languageCode,
                  en: 'No data available',
                  vi: 'Không có dữ liệu',
                ),
              ),
            );
          }

          final hourlyForecast = weatherProvider.hourlyForecast;
          ForecastModel selectedForecast =
              hourlyForecast[_selectedIndex.clamp(
                0,
                hourlyForecast.length - 1,
              )];
          final selectedTemp = _displayTemperature(
            selectedForecast.temp,
            settings.temperatureUnit,
          );
          final selectedWind = _displayWind(
            selectedForecast.windSpeed,
            settings.windSpeedUnit,
          );
          final selectedTime = DateFormat(
            _timePattern(settings.timeFormat),
          ).format(DateTime.parse(selectedForecast.dt));

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Info
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentCity,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppStrings.tr(
                            languageCode,
                            en: 'Next 48 hours',
                            vi: '48 giờ tới',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Temperature Chart
                  HourlyChart(
                    hourlyForecast: hourlyForecast,
                    temperatureUnit: settings.temperatureUnit,
                    timeFormat: settings.timeFormat,
                  ),
                  const SizedBox(height: 24),

                  // Selected Hour Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedTime,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  selectedForecast.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${selectedTemp.toStringAsFixed(0)}°',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _DetailTile(
                              icon: Icons.opacity,
                              label: 'Humidity',
                              value: '${selectedForecast.humidity}%',
                            ),
                            _DetailTile(
                              icon: Icons.air,
                              label: 'Wind',
                              value: selectedWind,
                            ),
                            _DetailTile(
                              icon: Icons.cloud,
                              label: 'Cloud',
                              value: '${selectedForecast.cloudiness}%',
                            ),
                            _DetailTile(
                              icon: Icons.water_drop,
                              label: 'Precipitation',
                              value:
                                  '${(selectedForecast.precipitation * 100).toStringAsFixed(0)}%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Hourly List
                  Text(
                    AppStrings.tr(
                      languageCode,
                      en: 'Hourly Details',
                      vi: 'Chi tiết theo giờ',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: hourlyForecast.length,
                      itemBuilder: (context, index) {
                        return HourlyItem(
                          forecast: hourlyForecast[index],
                          isSelected: _selectedIndex == index,
                          temperatureUnit: settings.temperatureUnit,
                          timeFormat: settings.timeFormat,
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _displayTemperature(double celsiusValue, TemperatureUnit unit) {
    if (unit == TemperatureUnit.fahrenheit) {
      return UnitConverter.celsiusToFahrenheit(celsiusValue);
    }
    return celsiusValue;
  }

  String _displayWind(double kmhValue, WindSpeedUnit unit) {
    if (unit == WindSpeedUnit.mph) {
      final mph = kmhValue * 0.621371;
      return '${mph.toStringAsFixed(1)} mph';
    }
    return '${kmhValue.toStringAsFixed(1)} km/h';
  }

  String _timePattern(TimeFormat format) {
    return format == TimeFormat.h24 ? 'HH:mm' : 'h:mm a';
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
