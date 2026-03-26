import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/app_strings.dart';
import 'sv2_screens/home_screen/home_screen.dart';
import 'OnboardingAndUserPreferencesScreens/location_setup_screen/search_location_screen.dart';
import 'OnboardingAndUserPreferencesScreens/location_setup_screen/models/location_choice.dart';
import '../features/map_view_screen/map_view_screen.dart';
import '../features/compare_locations_screen/compare_locations_screen.dart';

class MainWrapperScreen extends StatefulWidget {
  final LocationChoice? initialLocation;

  const MainWrapperScreen({super.key, this.initialLocation});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // If an initial location is provided (from onboarding), fetch its weather
    if (widget.initialLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final weatherProvider = context.read<WeatherProvider>();
        weatherProvider.fetchWeatherByCoordinates(
          widget.initialLocation!.latitude,
          widget.initialLocation!.longitude,
          locationName: widget.initialLocation!.fullName,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;
    final colorScheme = Theme.of(context).colorScheme;
    final List<Widget> screens = [
      HomeScreen(
        onNavigateToCompare: () {
          final weatherProvider = context.read<WeatherProvider>();
          if (weatherProvider.currentWeather != null) {
            weatherProvider.addWeatherToCompare(
              weatherProvider.currentWeather!,
            );
          }
          setState(() {
            _currentIndex = 3;
          });
        },
      ),
      SearchLocationScreen(
        onCitySelected: (city) {
          // Update weather data using coordinates (more reliable than city name)
          final weatherProvider = context.read<WeatherProvider>();
          weatherProvider.fetchWeatherByCoordinates(
            city.latitude,
            city.longitude,
            locationName: city.fullName,
          );

          setState(() {
            _currentIndex = 0; // Switch back to Home tab
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppStrings.tr(languageCode, en: 'Switched to', vi: 'Đã chuyển đến')} ${city.fullName}',
              ),
            ),
          );
        },
        onCompareCity: (city) {
          final weatherProvider = context.read<WeatherProvider>();
          weatherProvider.addCityToCompare(city.city);

          setState(() {
            _currentIndex = 3; // Switch to Compare tab
          });
        },
      ),
      const MapViewScreen(),
      CompareLocationsScreen(
        onNavigateToSearch: () {
          setState(() {
            _currentIndex = 1; // Switch to Search tab
          });
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppStrings.tr(languageCode, en: 'Home', vi: 'Trang chủ'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: AppStrings.tr(languageCode, en: 'Search', vi: 'Tìm kiếm'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: AppStrings.tr(languageCode, en: 'Map', vi: 'Bản đồ'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.compare_arrows),
            label: AppStrings.tr(languageCode, en: 'Compare', vi: 'So sánh'),
          ),
        ],
      ),
    );
  }
}
