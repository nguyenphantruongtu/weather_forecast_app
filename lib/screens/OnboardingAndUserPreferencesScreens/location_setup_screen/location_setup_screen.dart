import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../settings_screen/settings_screen.dart';
import 'widgets/location_option_card.dart';
import 'widgets/permission_dialog.dart';

/// Màn hình cấu hình vị trí (Màn 2 - Welcome & Location Setup)
/// Cho phép người dùng chọn vị trí ban đầu
class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCity;
  bool _isLoading = false;

  /// Danh sách các thành phố phổ biến
  final List<String> _popularCities = [
    'Hanoi, Vietnam',
    'Ho Chi Minh City, Vietnam',
    'Da Nang, Vietnam',
    'London, UK',
    'New York, USA',
    'Tokyo, Japan',
    'Sydney, Australia',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Lấy vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    // Kiểm tra quyền
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Nếu chưa được hỏi, hiển thị dialog xin quyền
      bool? allowed = await PermissionDialog.show(
        context,
        title: 'Access Your Location',
        message:
            'We need your location to provide accurate weather information.',
      );

      if (allowed != true) return;

      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Nếu người dùng từ chối vĩnh viễn, hiển thị thông báo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permission is denied forever. Enable it in app settings.'),
          ),
        );
      }
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        // desiredAccuracy: độ chính xác cao
      );

      // Chuyển đổi tọa độ thành tên thành phố
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String cityName =
            '${place.locality}, ${place.country}';
        // isNotEmpty: danh sách không rỗng

        setState(() => _selectedCity = cityName);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected: $cityName')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Tìm kiếm thành phố
  void _searchCity() {
    String query = _searchController.text.trim();
    // trim(): xóa khoảng trắng ở đầu và cuối

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a city name')),
      );
      return;
    }

    setState(() => _selectedCity = query);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: $query')),
    );
  }

  /// Di chuyển sang Settings Screen
  void _continueToSettings() {
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city first')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        elevation: 0,
        // elevation: xóa shadow
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // SingleChildScrollView: cho phép scroll khi content vượt quá màn hình
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề
                    Text(
                      'Choose how to find your location',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),

                    // Option 1: Current Location
                    LocationOptionCard(
                      title: 'Use Current Location',
                      description: 'Auto-detect your location using GPS',
                      icon: Icons.location_on,
                      backgroundColor: Colors.blue.shade50,
                      onTap: _getCurrentLocation,
                    ),

                    // Option 2: Search City
                    LocationOptionCard(
                      title: 'Search City',
                      description: 'Find and select any city manually',
                      icon: Icons.search,
                      backgroundColor: Colors.green.shade50,
                      onTap: () => _showSearchDialog(),
                    ),

                    // Option 3: Popular Cities
                    LocationOptionCard(
                      title: 'Popular Cities',
                      description: 'Choose from our list of popular cities',
                      icon: Icons.public,
                      backgroundColor: Colors.orange.shade50,
                      onTap: () => _showPopularCitiesDialog(),
                    ),

                    const SizedBox(height: 32),

                    // Info về vị trí đã chọn
                    if (_selectedCity != null) ...[ 
                      // ... (spread operator): mở rộng list
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Selected Location'),
                                  Text(
                                    _selectedCity!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Nút Continue
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continueToSettings,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Dialog tìm kiếm thành phố
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search City'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter city name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _searchCity();
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  /// Dialog chọn thành phố phổ biến
  void _showPopularCitiesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Popular Cities'),
        content: SizedBox(
          width: double.maxFinite,
          // maxFinite: chiều rộng tối đa có sẵn
          child: ListView.builder(
            itemCount: _popularCities.length,
            itemBuilder: (context, index) {
              return ListTile(
                // ListTile: widget chiếu diễn một item trong list
                title: Text(_popularCities[index]),
                onTap: () {
                  setState(() => _selectedCity = _popularCities[index]);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: ${_popularCities[index]}')),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}