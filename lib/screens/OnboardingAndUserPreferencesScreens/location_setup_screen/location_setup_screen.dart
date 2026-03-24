import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
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
                    foregroundColor: const Color(0xFFB6BCCB),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Skip'),
                ),
              ),
              const Text(
                'Welcome! 🌤️',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C2232),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let\'s set up your location to get accurate\nweather updates',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8A93A8),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE8ECF5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    LocationOptionCard(
                      title: 'Use Current\nLocation',
                      description: 'GPS-based location',
                      icon: Icons.my_location,
                      trailingIcon: Icons.push_pin,
                      onTap: _openPermissionFlow,
                    ),
                    const SizedBox(height: 10),
                    LocationOptionCard(
                      title: 'Search Location',
                      description: 'Enter city manually',
                      icon: Icons.search,
                      trailingIcon: Icons.travel_explore,
                      iconColor: const Color(0xFF78A7EF),
                      onTap: _openSearchLocation,
                    ),
                    const SizedBox(height: 10),
                    LocationOptionCard(
                      title: 'Popular Cities',
                      description: 'Browse worldwide',
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
                    backgroundColor: const Color(0xFF4C9BF0),
                    disabledBackgroundColor: const Color(0xFFE5E7EF),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFFADB2C2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _selectedLocation == null
                        ? 'Continue'
                        : 'Continue (${_selectedLocation!.city})',
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
