import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../location_compare_screen/location_compare_screen.dart';
import '../location_search_screen/location_search_screen.dart';
import '../saved_locations_screen/saved_locations_screen.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:geocoding/geocoding.dart';
import '../../data/models/location_model.dart' as AppLocation;
import 'google_maps_integration.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  late MapController _mapController;
  List<Marker> _markers = [];
  
  // Trạng thái lưu lớp bản đồ hiện hành
  String _currentWeatherLayer = 'none'; 
  // TODO: Thay YOUR_API_KEY bằng API Key thật của OpenWeatherMap
  final String _openWeatherApiKey = '217b719f20e6ea5bdd5e3c45efd89d65'; 

  // State cho thanh tìm kiếm nổi
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;
  bool _hasResult = false;
  String _searchedCityName = '';
  double _searchedLatitude = 0.0;
  double _searchedLongitude = 0.0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _updateMarkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateMarkers() {
    final provider = Provider.of<LocationProvider>(context, listen: false);
    
    // Khởi tạo danh sách marker rỗng
    _markers = [];
    
    // Chỉ kiểm tra biến lưu trữ thành phố đang được chọn/tìm kiếm
    if (provider.selectedCity != null) {
      // Add DUY NHẤT 1 Marker của tọa độ đó vào danh sách _markers
      _markers.add(
        Marker(
          point: LatLng(provider.selectedCity!.latitude, provider.selectedCity!.longitude),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }
    // Nếu selectedCity bị null, bản đồ không hiện Marker nào
  }

  // Xử lý Tìm kiếm: Khi submit thanh tìm kiếm
  Future<void> _handleSearch(String text) async {
    if (text.isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _hasResult = false;
    });

    try {
      // Sử dụng GoogleMapsIntegration để chuyển text thành tọa độ
      final googleMapsIntegration = GoogleMapsIntegration();
      final location = await googleMapsIntegration.getLocationFromAddress(text);
      
      if (location != null) {
        _searchedLatitude = location.latitude;
        _searchedLongitude = location.longitude;
        _searchedCityName = text;
        
        // Xóa danh sách marker cũ
        _markers.clear();
        
        // Tạo 1 Marker mới tại tọa độ vừa tìm được
        _markers.add(
          Marker(
            point: LatLng(location.latitude, location.longitude),
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
        
        // Cực kỳ quan trọng: Gọi _mapController.move để camera bản đồ tự động bay tới thành phố đó
        _mapController.move(LatLng(location.latitude, location.longitude), 11.0);
        
        // Kiểm tra xem thành phố đã được lưu yêu thích chưa
        final provider = Provider.of<LocationProvider>(context, listen: false);
        final searchedLocation = AppLocation.Location(
          id: '${text}_searched',
          name: text,
          latitude: location.latitude,
          longitude: location.longitude,
          country: '', // Có thể lấy từ location nếu cần
        );
        _isFavorite = provider.isFavorite(searchedLocation);

        setState(() {
          _isSearching = false;
          _hasResult = true;
        });
      } else {
        setState(() {
          _isSearching = false;
          _hasResult = false;
        });
        
        // Hiện SnackBar thông báo không tìm thấy địa điểm
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không tìm thấy địa điểm này"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _hasResult = false;
      });
      
      // Hiện SnackBar thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi tìm kiếm: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Xử lý Sự kiện Thả tim (OnTap Heart Icon)
  void _handleFavoriteTap() {
    if (!_hasResult) return;
    
    final provider = Provider.of<LocationProvider>(context, listen: false);
    final searchedLocation = AppLocation.Location(
      id: '${_searchedCityName}_searched',
      name: _searchedCityName,
      latitude: _searchedLatitude,
      longitude: _searchedLongitude,
      country: '',
    );
    
    // Gọi context.read<LocationProvider>().toggleFavorite(searchedLocation)
    provider.toggleFavorite(searchedLocation);
    
    // Cập nhật UI icon trái tim thành màu đỏ
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);

    // Xử lý selectedCity để thiết lập vị trí ban đầu
    LatLng initialCenter;
    double initialZoom;
    if (provider.selectedCity != null) {
      initialCenter = LatLng(provider.selectedCity!.latitude, provider.selectedCity!.longitude);
      initialZoom = 11.0;
    } else {
      // Mặc định: Hà Nội
      initialCenter = const LatLng(21.0285, 105.8542);
      initialZoom = 5.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bản đồ thời tiết"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Bản đồ
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: initialZoom,
              onTap: (_, latLng) {
                // Hiển thị popup khi nhấn vào bản đồ
                _showLocationPopup(latLng);
              },
            ),
            children: [
              // 1. Lớp bản đồ nền (Base Map)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.weather_forecast_app',
              ),
              
              // 2. Lớp thời tiết phủ lên trên (Overlay Weather Map)
              if (_currentWeatherLayer != 'none')
                TileLayer(
                  urlTemplate: 'https://tile.openweathermap.org/map/$_currentWeatherLayer/{z}/{x}/{y}.png?appid=$_openWeatherApiKey',
                ),

              // 3. Marker các vị trí
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          
          // Thanh tìm kiếm nổi (Floating Search Bar)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Thanh tìm kiếm
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm thành phố...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: _handleSearch,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Thẻ kết quả tìm kiếm nổi (Floating Result Card)
                  if (_isLoading)
                    const LinearProgressIndicator(),
                  
                  if (_hasResult && !_isLoading)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _searchedCityName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Nút Trái Tim (IconButton favorite_border hoặc favorite)
                          IconButton(
                            icon: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? Colors.red : Colors.grey,
                              size: 24,
                            ),
                            onPressed: _handleFavoriteTap,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Nút "Lớp dữ liệu" di chuyển xuống góc phải
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: _showLayerMenu,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    const Icon(Icons.layers, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      _getLayerName(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  // Hàm helper lấy tên hiển thị
  String _getLayerName() {
    switch (_currentWeatherLayer) {
      case 'temp_new': return "Nhiệt độ";
      case 'precipitation_new': return "Lượng mưa";
      case 'clouds_new': return "Mây";
      default: return "Mặc định";
    }
  }

  // Hàm hiển thị Menu chọn lớp
  void _showLayerMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Chọn lớp dữ liệu thời tiết", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.grey),
                title: const Text('Bản đồ gốc (Mặc định)'),
                trailing: _currentWeatherLayer == 'none' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _currentWeatherLayer = 'none');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.thermostat, color: Colors.orange),
                title: const Text('Bản đồ Nhiệt độ'),
                trailing: _currentWeatherLayer == 'temp_new' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _currentWeatherLayer = 'temp_new');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.blue),
                title: const Text('Bản đồ Lượng mưa / Radar'),
                trailing: _currentWeatherLayer == 'precipitation_new' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _currentWeatherLayer = 'precipitation_new');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud, color: Colors.blueGrey),
                title: const Text('Bản đồ Mây che phủ'),
                trailing: _currentWeatherLayer == 'clouds_new' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _currentWeatherLayer = 'clouds_new');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void _showLocationPopup(LatLng latLng) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.only(bottom: 20)),
              const Text("Vị trí đã chọn", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Vĩ độ: ${latLng.latitude.toStringAsFixed(4)}"),
              Text("Kinh độ: ${latLng.longitude.toStringAsFixed(4)}"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showWeatherAtLocation(latLng);
                    },
                    child: const Text("Xem thời tiết"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      MapsLauncher.launchCoordinates(latLng.latitude, latLng.longitude);
                    },
                    child: const Text("Mở bản đồ"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWeatherAtLocation(LatLng latLng) async {
    final provider = Provider.of<LocationProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await provider.fetchWeather(latLng.latitude, latLng.longitude);
    if (mounted) {
      Navigator.pop(context);
      _showWeatherBottomSheet(context, provider, "Vị trí đã chọn");
    }
  }

  void _showWeatherBottomSheet(BuildContext context, LocationProvider provider, String cityName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) {
        final w = provider.currentWeather;
        if (w == null) return const SizedBox(height: 150, child: Center(child: Text("Không có dữ liệu")));
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.only(bottom: 20)),
              Text(cityName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildInfoTile(Icons.thermostat, "Nhiệt độ", "${w['main']['temp']}°C", Colors.orange),
              _buildInfoTile(Icons.water_drop, "Độ ẩm", "${w['main']['humidity']}%", Colors.blue),
              _buildInfoTile(Icons.air, "Tốc độ gió", "${w['wind']['speed']} m/s", Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}