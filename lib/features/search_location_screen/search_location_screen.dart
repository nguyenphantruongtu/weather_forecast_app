import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../data/models/location_model.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [
    'Ho Chi Minh City, Vietnam',
    'Hanoi, Vietnam',
    'Da Nang, Vietnam',
    'Haiphong, Vietnam',
  ];
  
  List<Map<String, dynamic>> _popularCities = [
    {
      'name': 'Ho Chi Minh City',
      'country': 'Vietnam',
      'temperature': '28°'
    },
    {
      'name': 'Hanoi',
      'country': 'Vietnam', 
      'temperature': '25°'
    },
    {
      'name': 'New York',
      'country': 'USA',
      'temperature': '18°'
    },
    {
      'name': 'London',
      'country': 'UK',
      'temperature': '15°'
    },
    {
      'name': 'Tokyo',
      'country': 'Japan',
      'temperature': '22°'
    },
    {
      'name': 'Sydney',
      'country': 'Australia',
      'temperature': '20°'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search Location',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search city or location...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            // Use Current Location Button
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle current location
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D88FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.my_location, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Use Current Location',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Searches
            _buildSectionHeader('Recent Searches', Icons.access_time),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSearches.length,
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.access_time, color: Colors.grey[600]),
                  title: Text(
                    _recentSearches[index],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                    onPressed: () {
                      setState(() {
                        _recentSearches.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Popular Cities
            _buildSectionHeader('Popular Cities', Icons.whatshot),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _popularCities.length,
              itemBuilder: (context, index) {
                return PopularCityCard(city: _popularCities[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class PopularCityCard extends StatelessWidget {
  final Map<String, dynamic> city;

  const PopularCityCard({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D88FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  city['country'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Weather icon at bottom left
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.wb_sunny, color: Colors.white, size: 16),
            ),
          ),
          
          // Temperature at bottom right
          Positioned(
            bottom: 8,
            right: 8,
            child: Text(
              city['temperature'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Favorite button at top right
          Positioned(
            top: 8,
            right: 8,
            child: Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                // Tạo Location object để kiểm tra
                final location = Location(
                  id: '${city['name']}_${city['country']}',
                  name: city['name'],
                  latitude: 0.0, // Tạm thời để 0, cần lấy từ API
                  longitude: 0.0,
                  country: city['country'],
                );
                
                bool isFavorite = locationProvider.isFavorite(location);
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    locationProvider.toggleFavorite(location);
                    print('Toggled favorite for: ${city['name']}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}