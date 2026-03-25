import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/news_alert_model.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utils/app_strings.dart';
import '../../../../providers/weather_provider.dart';
import 'widgets/alert_card.dart';
import '../../../../screens/main_wrapper_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  AlertSeverity? _selectedSeverity;
  late List<AlertModel> _activeAlerts;

  @override
  void initState() {
    super.initState();
    _activeAlerts = [];

    Future.microtask(() {
      final provider = Provider.of<WeatherProvider>(context, listen: false);
      provider
          .fetchCurrentLocationWeather(); // Sử dụng GPS để lấy vị trí hiện tại
    });
  }

  List<AlertModel> get _filteredAlerts {
    if (_selectedSeverity == null) return _activeAlerts;
    return _activeAlerts.where((a) => a.severity == _selectedSeverity).toList();
  }

  /// Generate alerts based on current weather conditions
  void _updateAlertsFromWeather(dynamic currentWeather) {
    _activeAlerts.clear();

    if (currentWeather != null) {
      // Generate alerts based on weather conditions
      _generateAlertsFromWeather(currentWeather);
    }
  }

  /// Create alert list based on weather data
  void _generateAlertsFromWeather(weather) {
    int alertId = 1;

    // Heat Warning - if temp > 25°C
    if (weather.temperature > 25) {
      _activeAlerts.add(
        AlertModel(
          id: (alertId++).toString(),
          title: 'Excessive Heat Warning',
          description:
              'Dangerous heat conditions expected. High temperatures of ${weather.temperature.toStringAsFixed(1)}°C detected. Heat index values may reach ${(weather.temperature + 5).toStringAsFixed(1)}°C. Stay hydrated and avoid prolonged outdoor activities.',
          severity: weather.temperature > 30
              ? AlertSeverity.extreme
              : AlertSeverity.severe,
          type: AlertType.heat,
          location: weather.location,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 24)),
          updatedAt: DateTime.now(),
          impact: weather.temperature > 30 ? 'High Risk' : 'Moderate Risk',
          isActive: true,
        ),
      );
    }

    // High Wind Warning - if windSpeed > 20 km/h
    if (weather.windSpeed > 20) {
      _activeAlerts.add(
        AlertModel(
          id: (alertId++).toString(),
          title: 'High Wind Warning',
          description:
              'Strong winds with speeds of ${weather.windSpeed.toStringAsFixed(1)} km/h detected. Damaging winds and flying debris expected. Secure loose objects and avoid outdoor activities.',
          severity: weather.windSpeed > 50
              ? AlertSeverity.extreme
              : AlertSeverity.severe,
          type: AlertType.wind,
          location: weather.location,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 12)),
          updatedAt: DateTime.now(),
          impact: weather.windSpeed > 30 ? 'High Risk' : 'Moderate Risk',
          isActive: true,
        ),
      );
    }

    // Thunderstorm Warning - if description contains "Thunderstorm" or "Rain"
    if (weather.description.toLowerCase().contains('thunderstorm') ||
        weather.description.toLowerCase().contains('storm')) {
      _activeAlerts.add(
        AlertModel(
          id: (alertId++).toString(),
          title: 'Severe Thunderstorm Warning',
          description:
              'A severe thunderstorm warning has been issued for your area. ${weather.description}. Lightning, heavy rain, and damaging winds expected. Take shelter immediately.',
          severity: AlertSeverity.severe,
          type: AlertType.thunderstorm,
          location: weather.location,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 6)),
          updatedAt: DateTime.now(),
          impact: 'High Risk',
          isActive: true,
        ),
      );
    }

    // Flood Watch - if description contains "Rain" or "Rainy" and humidity > 80%
    if ((weather.description.toLowerCase().contains('rain') ||
            weather.description.toLowerCase().contains('rainy')) &&
        weather.humidity > 80) {
      _activeAlerts.add(
        AlertModel(
          id: (alertId++).toString(),
          title: 'Flash Flood Watch',
          description:
              'Conditions are favorable for flash flooding. Heavy rainfall with humidity at ${weather.humidity}% detected. Be prepared to evacuate low-lying areas. Avoid driving through flooded roads.',
          severity: AlertSeverity.moderate,
          type: AlertType.flood,
          location: weather.location,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 12)),
          updatedAt: DateTime.now(),
          impact: 'Moderate Risk',
          isActive: true,
        ),
      );
    }

    // Fog Warning - if description contains "Fog"
    if (weather.description.toLowerCase().contains('fog')) {
      _activeAlerts.add(
        AlertModel(
          id: (alertId++).toString(),
          title: 'Dense Fog Advisory',
          description:
              'Dense fog reduces visibility significantly. Use caution while driving and reduce speed. Use headlights and avoid unnecessary travel.',
          severity: AlertSeverity.minor,
          type: AlertType.fog,
          location: weather.location,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 8)),
          updatedAt: DateTime.now(),
          impact: 'Low Risk',
          isActive: true,
        ),
      );
    }

    // Cold Warning - if temp < 10°C
    if (weather.temperature < 10) {
      _activeAlerts.add(
        AlertModel(
          id: (alertId++).toString(),
          title: 'Extreme Cold Warning',
          description:
              'Dangerous cold conditions with temperatures of ${weather.temperature.toStringAsFixed(1)}°C. Frostbite can occur in minutes on exposed skin. Limit time outdoors and dress in layers.',
          severity: weather.temperature < 0
              ? AlertSeverity.extreme
              : AlertSeverity.severe,
          type: AlertType.cold,
          location: weather.location,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 24)),
          updatedAt: DateTime.now(),
          impact: weather.temperature < 5 ? 'High Risk' : 'Moderate Risk',
          isActive: true,
        ),
      );
    }

    // High UV Index Warning - if uvIndex > 8
    if (weather.uvIndex > 8) {
      _activeAlerts.add(
        AlertModel(
          id: (alertId++).toString(),
          title: 'High UV Index Alert',
          description:
              'UV index is very high at ${weather.uvIndex.toStringAsFixed(1)}. Prolonged sun exposure will cause rapid sunburn and skin damage. Seek shade and use sunscreen SPF 50+.',
          severity: AlertSeverity.moderate,
          type: AlertType.heat,
          location: weather.location,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 6)),
          updatedAt: DateTime.now(),
          impact: 'Moderate Risk',
          isActive: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        // Update alerts whenever weather changes
        _updateAlertsFromWeather(weatherProvider.currentWeather);

        final location =
            weatherProvider.currentWeather?.location ?? AppStrings.tr(languageCode, en: 'Turn on GPS to get location', vi: 'Bat GPS de lay vi tri');

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.home, color: colorScheme.onSurface),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainWrapperScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
            title: Text(
              AppStrings.tr(languageCode, en: 'Weather Alerts', vi: 'Canh bao thoi tiet'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            centerTitle: true,
          ),
          body: _buildActiveAlertsTab(weatherProvider, location, languageCode),
        );
      },
    );
  }

  Widget _buildActiveAlertsTab(
    WeatherProvider weatherProvider,
    String location,
    String languageCode,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // Fetch weather data again using GPS
        await weatherProvider.fetchCurrentLocationWeather();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location row
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF6B7AEF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          await weatherProvider.fetchCurrentLocationWeather();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF0FB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            size: 18,
                            color: Color(0xFF6B7AEF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Count & last updated
                  Row(
                    children: [
                      Text(
                        '${_activeAlerts.length} ${AppStrings.tr(languageCode, en: 'Active Alerts', vi: 'Canh bao dang hoat dong')}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    weatherProvider.currentWeather != null
                        ? AppStrings.tr(languageCode, en: 'Updated just now', vi: 'Vua cap nhat xong')
                        : AppStrings.tr(languageCode, en: 'Loading weather data...', vi: 'Dang tai du lieu thoi tiet...'),
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          '${AppStrings.tr(languageCode, en: 'All', vi: 'Tat ca')} (${_activeAlerts.length})',
                          null,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          AppStrings.tr(languageCode, en: 'Extreme', vi: 'Cuc doan'),
                          AlertSeverity.extreme,
                          dotColor: const Color(0xFFD32F2F),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          AppStrings.tr(languageCode, en: 'Severe', vi: 'Nghiem trong'),
                          AlertSeverity.severe,
                          dotColor: const Color(0xFFE65100),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          AppStrings.tr(languageCode, en: 'Moderate', vi: 'Trung binh'),
                          AlertSeverity.moderate,
                          dotColor: const Color(0xFFF57C00),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _activeAlerts.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.tr(languageCode, en: 'No active alerts', vi: 'Khong co canh bao dang hoat dong'),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.tr(languageCode, en: 'All conditions are normal', vi: 'Moi dieu kien deu binh thuong'),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final alert = _filteredAlerts[index];
                      return AlertCard(
                        alert: alert,
                        onTap: () => _showAlertDetail(alert),
                      );
                    }, childCount: _filteredAlerts.length),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    AlertSeverity? severity, {
    Color? dotColor,
  }) {
    final isSelected = _selectedSeverity == severity;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSeverity = isSelected ? null : severity;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B7AEF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B7AEF)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            if (dotColor != null && !isSelected) ...[
              const SizedBox(width: 5),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAlertDetail(AlertModel alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                alert.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(alert.location, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              Text(
                alert.description +
                    ' These conditions are expected to persist through the evening hours. Stay indoors and avoid unnecessary travel. If you must go outside, limit exposure and stay hydrated.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
