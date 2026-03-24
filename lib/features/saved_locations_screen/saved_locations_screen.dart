import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../location_search_screen/location_search_screen.dart';
import '../../providers/location_provider.dart';
import '../../data/models/location_model.dart' as AppLocation;

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  // State cho Edit Mode
  bool _isEditMode = false;
  Set<String> _selectedLocations = {}; // Lưu ID các location đang được chọn để xóa

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final savedLocations = locationProvider.savedLocations;

    print('SavedLocationsScreen: ${savedLocations.length} locations');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Locations',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          // Nút Edit/Cancel
          TextButton(
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
                if (!_isEditMode) {
                  _selectedLocations.clear();
                }
              });
            },
            child: Text(
              _isEditMode ? 'Cancel' : 'Edit',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header row
            _buildHeaderRow(),

            const SizedBox(height: 16),

            // List of saved locations
            Expanded(
              child: Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  final savedLocations = locationProvider.savedLocations;
                  return savedLocations.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: savedLocations.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final location = savedLocations[index];
                          return SavedLocationCard(
                            location: {
                              'name': location.name,
                              'country': location.country,
                              'weatherIcon': Icons.wb_sunny,
                              'temperature': '25°',
                              'description': 'Sunny',
                              'highTemp': '32°',
                              'lowTemp': '24°',
                              'humidity': '65%',
                              'windSpeed': '12 km/h',
                              'precipitation': '0%',
                            },
                            locationModel: location,
                            isEditMode: _isEditMode,
                            isSelected: _selectedLocations.contains(location.id),
                            onToggleSelection: (bool isSelected) {
                              setState(() {
                                if (isSelected) {
                                  _selectedLocations.add(location.id);
                                } else {
                                  _selectedLocations.remove(location.id);
                                }
                              });
                            },
                            onDelete: () {
                              // Xóa location khỏi danh sách yêu thích
                              locationProvider.toggleFavorite(location);
                              setState(() {
                                _selectedLocations.remove(location.id);
                              });
                            },
                          );
                        },
                      );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isEditMode 
        ? FloatingActionButton.extended(
            onPressed: () {
              // Xóa các location đã chọn
              if (_selectedLocations.isNotEmpty) {
                final locationProvider = Provider.of<LocationProvider>(context, listen: false);
                final locationsToDelete = locationProvider.savedLocations
                  .where((loc) => _selectedLocations.contains(loc.id))
                  .toList();
                
                for (final location in locationsToDelete) {
                  locationProvider.toggleFavorite(location);
                }
                
                setState(() {
                  _selectedLocations.clear();
                  _isEditMode = false;
                });
              }
            },
            backgroundColor: Colors.red,
            icon: const Icon(Icons.delete),
            label: Text('Delete (${_selectedLocations.length})'),
          )
        : FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LocationSearchScreen()));
            },
            backgroundColor: const Color(0xFF2D88FF),
            child: const Icon(Icons.add, color: Colors.white),
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No saved locations yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find locations and tap the heart icon to save them',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final savedLocations = locationProvider.savedLocations;
        return Row(
          children: [
            Text(
              '${savedLocations.length} saved locations',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // Compare locations
              },
              icon: const Icon(Icons.bar_chart, size: 16, color: Colors.grey),
              label: const Text(
                'Compare',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SavedLocationCard extends StatelessWidget {
  final Map<String, dynamic> location;
  final AppLocation.Location locationModel;
  final bool isEditMode;
  final bool isSelected;
  final Function(bool) onToggleSelection;
  final VoidCallback onDelete;

  const SavedLocationCard({
    super.key, 
    required this.location,
    required this.locationModel,
    required this.isEditMode,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main content row
            Row(
              children: [
                // Checkbox cho Edit Mode
                if (isEditMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      onToggleSelection(value ?? false);
                    },
                  ),
                
                // Left column: Location info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location['country'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Right column: Weather info
                Column(
                  children: [
                    Icon(
                      location['weatherIcon'],
                      size: 48,
                      color: const Color(0xFF2D88FF),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location['temperature'],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom stats row
            Container(
              height: 1,
              color: Colors.grey[200],
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.trending_up, location['highTemp'], 'High'),
                _buildStatItem(Icons.trending_down, location['lowTemp'], 'Low'),
                _buildStatItem(Icons.water_drop, location['humidity'], 'Humidity'),
                _buildStatItem(Icons.air, location['windSpeed'], 'Wind'),
                _buildStatItem(Icons.opacity, location['precipitation'], 'Precip'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}