import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utils/app_strings.dart';
import 'location_permission_screen.dart';
import 'location_success_screen.dart';
import 'models/location_choice.dart';
import 'popular_cities_screen.dart';
import 'search_location_screen.dart';
import 'services/location_api_service.dart';
import 'widgets/location_option_card.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  LocationChoice? _selectedLocation;
  final LocationApiService _locationApiService = LocationApiService();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _handleSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurface.withValues(alpha: 0.65),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(AppStrings.tr(languageCode, en: 'Skip', vi: 'Bo qua')),
                ),
              ),
              Text(
                AppStrings.tr(languageCode, en: 'Welcome! 🌤️', vi: 'Chao mung! 🌤️'),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.tr(
                  languageCode,
                  en: 'Let\'s set up your location to get accurate\nweather updates',
                  vi: 'Hay cai dat vi tri de nhan\nthong tin thoi tiet chinh xac',
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              const Center(child: _LocationIllustration()),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    LocationOptionCard(
                      title: AppStrings.tr(languageCode, en: 'Use Current\nLocation', vi: 'Dung vi tri\nhien tai'),
                      description: AppStrings.tr(languageCode, en: 'GPS-based location', vi: 'Vi tri theo GPS'),
                      icon: Icons.my_location,
                      trailingIcon: Icons.push_pin,
                      onTap: _openPermissionFlow,
                    ),
                    const SizedBox(height: 10),
                    LocationOptionCard(
                      title: AppStrings.tr(languageCode, en: 'Search Location', vi: 'Tim vi tri'),
                      description: AppStrings.tr(languageCode, en: 'Enter city manually', vi: 'Nhap thanh pho thu cong'),
                      icon: Icons.search,
                      trailingIcon: Icons.travel_explore,
                      iconColor: const Color(0xFF78A7EF),
                      onTap: _openSearchLocation,
                    ),
                    const SizedBox(height: 10),
                    LocationOptionCard(
                      title: AppStrings.tr(languageCode, en: 'Popular Cities', vi: 'Thanh pho pho bien'),
                      description: AppStrings.tr(languageCode, en: 'Browse worldwide', vi: 'Duyet toan cau'),
                      icon: Icons.public,
                      trailingIcon: Icons.public,
                      iconColor: const Color(0xFF6BC89C),
                      onTap: _openPopularCities,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedLocation == null
                      ? null
                      : () => _goToSuccess(_selectedLocation!),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
                    foregroundColor: colorScheme.onPrimary,
                    disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.45),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _selectedLocation == null
                        ? AppStrings.tr(languageCode, en: 'Continue', vi: 'Tiep tuc')
                        : '${AppStrings.tr(languageCode, en: 'Continue', vi: 'Tiep tuc')} (${_selectedLocation!.city})',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPermissionFlow() async {
    final result = await Navigator.of(context).push<LocationChoice>(
      MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
    );

    if (result != null && mounted) {
      setState(() => _selectedLocation = result);
      _goToSuccess(result);
    }
  }

  Future<void> _openSearchLocation() async {
    final result = await Navigator.of(context).push<LocationChoice>(
      MaterialPageRoute(builder: (_) => const SearchLocationScreen()),
    );

    if (result != null && mounted) {
      setState(() => _selectedLocation = result);
    }
  }

  Future<void> _openPopularCities() async {
    final result = await Navigator.of(context).push<LocationChoice>(
      MaterialPageRoute(builder: (_) => const PopularCitiesScreen()),
    );

    if (result != null && mounted) {
      setState(() => _selectedLocation = result);
    }
  }

  Future<void> _handleSkip() async {
    if (_selectedLocation != null) {
      _goToSuccess(_selectedLocation!);
      return;
    }

    try {
      final popular = await _locationApiService.getPopularCities();
      if (!mounted) return;
      if (popular.isNotEmpty) {
        _goToSuccess(popular.first);
        return;
      }
    } catch (_) {
      // Fallback below keeps the flow unblocked when API is unavailable.
    }

    if (!mounted) return;
    _goToSuccess(
      const LocationChoice(city: 'Hanoi', country: 'Vietnam'),
    );
  }

  void _goToSuccess(LocationChoice location) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocationSuccessScreen(location: location),
      ),
    );
  }
}

class _LocationIllustration extends StatelessWidget {
  const _LocationIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 170,
            height: 170,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8EEF9),
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFF5A9EEB),
              borderRadius: BorderRadius.circular(38),
            ),
            child: const Icon(Icons.place, color: Colors.white, size: 36),
          ),
          Positioned(
            top: 52,
            right: 38,
            child: _dotNode(Colors.amber.shade500, Icons.wb_sunny),
          ),
          Positioned(
            left: 30,
            bottom: 52,
            child: _dotNode(Colors.blue.shade200, Icons.cloud),
          ),
          Positioned(
            right: 62,
            bottom: 30,
            child: _dotNode(Colors.grey.shade300, Icons.air),
          ),
        ],
      ),
    );
  }

  Widget _dotNode(Color color, IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: color.withOpacity(0.25), shape: BoxShape.circle),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
