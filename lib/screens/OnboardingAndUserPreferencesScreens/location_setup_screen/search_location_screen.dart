import 'dart:async';

import 'package:flutter/material.dart';
import 'models/location_choice.dart';
import 'services/location_api_service.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

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
    final hasQuery = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Search Location',
          style: TextStyle(
            fontSize: 19,
            color: Color(0xFF1C2232),
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
                hintText: 'Enter city name',
                hintStyle: const TextStyle(color: Color(0xFFA6ABBA)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFA6ABBA)),
                filled: true,
                fillColor: const Color(0xFFF0F2F7),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!hasQuery) ...[
              const Text(
                'RECENT SEARCHES',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.6,
                  color: Color(0xFFADB3C2),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (_recentSearches.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'No recent searches yet.',
                    style: TextStyle(color: Color(0xFFB3B9C8), fontSize: 12),
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
              const Text(
                'POPULAR CITIES',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.6,
                  color: Color(0xFFADB3C2),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE6EAF2)),
                  ),
                  child: _isSearching
                      ? const Center(child: CircularProgressIndicator())
                      : _searchResults.isEmpty
                          ? const Center(
                              child: Text(
                                'No cities found',
                                style: TextStyle(color: Color(0xFFAAB1C2)),
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
                                  trailing: Text(
                                    location.emoji,
                                    style: const TextStyle(fontSize: 18),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load popular cities.')),
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
    Navigator.pop(context, city);
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
