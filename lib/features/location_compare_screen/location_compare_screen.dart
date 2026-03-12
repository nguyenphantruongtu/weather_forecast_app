import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';

class LocationCompareScreen extends StatefulWidget {
  const LocationCompareScreen({super.key});

  @override
  State<LocationCompareScreen> createState() => _LocationCompareScreenState();
}

class _LocationCompareScreenState extends State<LocationCompareScreen> {
  Map<String, Map<String, dynamic>> _weatherData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cập nhật dữ liệu khi danh sách so sánh thay đổi
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    final provider = Provider.of<LocationProvider>(context, listen: false);
    final items = provider.compareList;
    
    if (items.length < 2) return;

    setState(() {
      _isLoading = true;
      _weatherData.clear();
    });

    // Gọi API để lấy thời tiết cho từng địa điểm
    for (var loc in items) {
      try {
        // Fetch weather for this specific location
        final weather = await provider.fetchWeatherData(loc.lat, loc.lon);
        if (weather != null) {
          _weatherData[loc.uniqueId] = weather;
        }
      } catch (e) {
        print("Lỗi lấy thời tiết cho ${loc.name}: $e");
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);
    final items = provider.compareList;

    return Scaffold(
      appBar: AppBar(
        title: const Text("So sánh thời tiết"),
        actions: [
          IconButton(
            onPressed: () {
              provider.clearCompare();
              setState(() {
                _weatherData.clear();
              });
            }, 
            icon: const Icon(Icons.delete_sweep)
          )
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text("Hãy chọn ít nhất 2 địa điểm để so sánh"))
          : _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              child: Column(
                children: [
                  // Tiêu đề các cột
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      for (var loc in items)
                        Expanded(
                          child: Center(
                            child: Column(
                              children: [
                                Text(loc.name, 
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 16
                                  )
                                ),
                                Text(loc.country, 
                                  style: const TextStyle(color: Colors.grey)
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 40),
                  
                  // Các chỉ số thời tiết để so sánh
                  _buildCompareRow(Icons.thermostat, "Nhiệt độ", "temp", "°C"),
                  _buildCompareRow(Icons.water_drop, "Độ ẩm", "humidity", "%"),
                  _buildCompareRow(Icons.air, "Tốc độ gió", "speed", "m/s"),
                  _buildCompareRow(Icons.visibility, "Tầm nhìn", "visibility", "m"),
                  
                  const SizedBox(height: 20),
                  
                  // Nút xóa từng địa điểm
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      for (var loc in items)
                        Expanded(
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                provider.toggleCompare(loc);
                                setState(() {
                                  _weatherData.remove(loc.uniqueId);
                                });
                              },
                              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildCompareRow(IconData icon, String label, String weatherKey, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          for (var loc in Provider.of<LocationProvider>(context).compareList)
            Expanded(
              child: Center(
                child: _buildWeatherValue(loc.uniqueId, weatherKey, unit),
              ),
            ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildWeatherValue(String uniqueId, String weatherKey, String unit) {
    final weather = _weatherData[uniqueId];
    if (weather == null) {
      return const Text("--", style: TextStyle(color: Colors.grey));
    }

    // Xử lý các key khác nhau trong response
    dynamic value;
    if (weatherKey == "temp") {
      value = weather['main']?['temp'];
    } else if (weatherKey == "humidity") {
      value = weather['main']?['humidity'];
    } else if (weatherKey == "speed") {
      value = weather['wind']?['speed'];
    } else if (weatherKey == "visibility") {
      value = weather['visibility'];
    }

    if (value == null) {
      return const Text("--", style: TextStyle(color: Colors.grey));
    }

    return Text(
      "${value.toString()}$unit",
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
