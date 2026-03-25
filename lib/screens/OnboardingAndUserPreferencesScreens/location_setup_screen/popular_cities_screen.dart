import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utils/app_strings.dart';
import 'models/location_choice.dart';
import 'services/location_api_service.dart';

class PopularCitiesScreen extends StatefulWidget {
  const PopularCitiesScreen({super.key});

  @override
  State<PopularCitiesScreen> createState() => _PopularCitiesScreenState();
}

class _PopularCitiesScreenState extends State<PopularCitiesScreen> {
  int _tab = 0;
  bool _isLoading = true;
  final LocationApiService _locationApiService = LocationApiService();

  final List<String> _tabs = const ['All', 'Asia', 'Europe', 'America'];
  List<LocationChoice> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          AppStrings.tr(languageCode, en: 'Popular Cities', vi: 'Thanh pho pho bien'),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Text(
                      AppStrings.tr(languageCode, en: 'FEATURED', vi: 'NOI BAT'),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _cities.length < 4 ? _cities.length : 4,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final city = _cities[index];
                        return _featuredCard(city);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final active = _tab == index;
                        return GestureDetector(
                          onTap: () => setState(() => _tab = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color:
                                  active ? const Color(0xFF4C9BF0) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: active
                                    ? const Color(0xFF4C9BF0)
                                    : const Color(0xFFDCE2EF),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _localizedTab(_tabs[index], languageCode),
                              style: TextStyle(
                                fontSize: 12,
                                color: active
                                    ? Colors.white
                                    : const Color(0xFF6E768A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredCities.length,
                      itemBuilder: (context, index) {
                        final city = _filteredCities[index];
                        return _cityTile(city);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<LocationChoice> get _filteredCities {
    final tabName = _tabs[_tab];
    if (tabName == 'All') return _cities;
    return _cities.where((item) => item.region == tabName).toList();
  }

  String _localizedTab(String tab, String languageCode) {
    switch (tab) {
      case 'All':
        return AppStrings.tr(languageCode, en: 'All', vi: 'Tat ca');
      case 'Asia':
        return AppStrings.tr(languageCode, en: 'Asia', vi: 'Chau A');
      case 'Europe':
        return AppStrings.tr(languageCode, en: 'Europe', vi: 'Chau Au');
      case 'America':
        return AppStrings.tr(languageCode, en: 'America', vi: 'Chau My');
      default:
        return tab;
    }
  }

  Future<void> _loadCities() async {
    try {
      final cities = await _locationApiService.getPopularCities();
      if (!mounted) return;
      setState(() {
        _cities = cities;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load popular cities from API.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _featuredCard(LocationChoice city) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, city),
      child: Container(
        width: 128,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFF37954), Color(0xFFF95B8D)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              city.city,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            Text(
              '${city.temperature}°',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                city.condition,
                style: const TextStyle(
                  color: Color(0xFFFCEEF4),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cityTile(LocationChoice city) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, city),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EAF3)),
        ),
        child: Row(
          children: [
            Text(
              '${city.temperature}°',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D2436),
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city.city,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D2436),
                    ),
                  ),
                  Text(
                    city.country,
                    style: const TextStyle(color: Color(0xFF99A1B4), fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(city.emoji, style: const TextStyle(fontSize: 21)),
          ],
        ),
      ),
    );
  }
}
