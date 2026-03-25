import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utils/app_strings.dart';
import 'models/location_choice.dart';
import 'services/location_api_service.dart';

class SearchLocationScreen extends StatefulWidget {
  final Function(LocationChoice)? onCitySelected;
  final Function(LocationChoice)? onCompareCity;

  const SearchLocationScreen({super.key, this.onCitySelected, this.onCompareCity});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController _controller = TextEditingController();
  final LocationApiService _locationApiService = LocationApiService();
  final List<LocationChoice> _recentSearches = [];

  List<LocationChoice> _popularCities = [];
  List<LocationChoice> _searchResults = [];
  bool _isLoadingPopular = true;
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPopularCities();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;
    final colorScheme = Theme.of(context).colorScheme;
    final hasQuery = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          AppStrings.tr(languageCode, en: 'Search Location', vi: 'Tim vi tri'),
          style: TextStyle(
            fontSize: 19,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: AppStrings.tr(languageCode, en: 'Enter city name', vi: 'Nhap ten thanh pho'),
                hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!hasQuery) ...[
              Text(
                AppStrings.tr(languageCode, en: 'RECENT SEARCHES', vi: 'TIM KIEM GAN DAY'),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.6,
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (_recentSearches.isEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    AppStrings.tr(languageCode, en: 'No recent searches yet.', vi: 'Chua co tim kiem gan day.'),
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                  ),
                )
              else
                ..._recentSearches.take(2).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _recentItem(item),
                  );
                }),
              const SizedBox(height: 20),
              Text(
                AppStrings.tr(languageCode, en: 'POPULAR CITIES', vi: 'THANH PHO PHO BIEN'),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.6,
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoadingPopular
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.55,
                        children: _popularCities.take(4).map(_popularTile).toList(),
                      ),
              ),
            ] else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: _isSearching
                      ? const Center(child: CircularProgressIndicator())
                      : _searchResults.isEmpty
                          ? Center(
                              child: Text(
                                AppStrings.tr(languageCode, en: 'No cities found', vi: 'Khong tim thay thanh pho'),
                                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _searchResults.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1, indent: 14),
                              itemBuilder: (context, index) {
                                final location = _searchResults[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    location.city,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(location.country),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        location.emoji,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.compare_arrows, color: colorScheme.primary),
                                        onPressed: () {
                                          if (widget.onCompareCity != null) {
                                            widget.onCompareCity!(location);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () => _selectCity(location),
                                );
                              },
                            ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadPopularCities() async {
    try {
      final list = await _locationApiService.getPopularCities();
      if (!mounted) return;
      setState(() {
        _popularCities = list;
      });
    } catch (_) {
      if (!mounted) return;
      final languageCode = context.read<SettingsProvider>().settings.language;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr(languageCode, en: 'Could not load popular cities.', vi: 'Khong the tai danh sach thanh pho pho bien.'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPopular = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final results = await _locationApiService.searchCities(query, count: 6);
        if (!mounted) return;
        setState(() {
          _searchResults = results;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _searchResults = [];
        });
      } finally {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  void _selectCity(LocationChoice city) {
    _recentSearches.removeWhere(
      (item) => item.city == city.city && item.country == city.country,
    );
    _recentSearches.insert(0, city);
    if (widget.onCitySelected != null) {
      widget.onCitySelected!(city);
    } else {
      Navigator.pop(context, city);
    }
  }

  Widget _recentItem(LocationChoice city) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectCity(city),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8ECF4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xFFA7ADBC), size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${city.city}\n${city.country}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF424B60),
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.compare_arrows, color: Color(0xFFA7ADBC)),
                onPressed: () {
                  if (widget.onCompareCity != null) widget.onCompareCity!(city);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _popularTile(LocationChoice city) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectCity(city),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8ECF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(city.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                city.city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E2537),
                  fontSize: 12,
                ),
              ),
              Text(
                city.country,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF9CA3B6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
