import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../data/models/location_model.dart';

class WeatherDetailScreen extends StatefulWidget {
  final Location location;

  const WeatherDetailScreen({super.key, required this.location});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  late LocationProvider _locationProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _locationProvider.fetchWeather(
        widget.location.latitude,
        widget.location.longitude,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu thời tiết: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherData = _locationProvider.currentWeather;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.location.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildLoadingIndicator()
          : _buildWeatherContent(weatherData),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.lightBlue,
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải dữ liệu thời tiết...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(Map<String, dynamic>? weatherData) {
    if (weatherData == null) {
      return const Center(
        child: Text(
          'Không có dữ liệu thời tiết',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather header with icon and temperature
          _buildWeatherHeader(weatherData),
          
          const SizedBox(height: 24),

          // Weather details grid
          _buildWeatherDetails(weatherData),

          const SizedBox(height: 24),

          // Additional information
          _buildAdditionalInfo(weatherData),
        ],
      ),
    );
  }

  Widget _buildWeatherHeader(Map<String, dynamic> weatherData) {
    final weather = weatherData['weather'][0];
    final main = weatherData['main'];
    final wind = weatherData['wind'];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Weather icon and main info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://openweathermap.org/img/wn/${weather['icon']}@2x.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${main['temp'].toInt()}°',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weather['description'].toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Feels like and location
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Cảm giác như',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${main['feels_like'].toInt()}°',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Độ ẩm',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${main['humidity']}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Gió',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${wind['speed']} m/s',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetails(Map<String, dynamic> weatherData) {
    final main = weatherData['main'];
    final wind = weatherData['wind'];
    final visibility = weatherData['visibility'];
    final clouds = weatherData['clouds'];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết thời tiết',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDetailRow(Icons.thermostat, 'Nhiệt độ cao nhất', '${main['temp_max'].toInt()}°', Colors.orange),
            _buildDetailRow(Icons.thermostat, 'Nhiệt độ thấp nhất', '${main['temp_min'].toInt()}°', Colors.blue),
            _buildDetailRow(Icons.water_drop, 'Độ ẩm', '${main['humidity']}%', Colors.blue),
            _buildDetailRow(Icons.air, 'Tốc độ gió', '${wind['speed']} m/s', Colors.green),
            _buildDetailRow(Icons.visibility, 'Tầm nhìn', '${(visibility / 1000).toStringAsFixed(1)} km', Colors.grey),
            _buildDetailRow(Icons.percent, 'Độ che phủ mây', '${clouds['all']}%', Colors.grey),
            _buildDetailRow(Icons.speed, 'Áp suất', '${main['pressure']} hPa', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(Map<String, dynamic> weatherData) {
    final sys = weatherData['sys'];
    final timezone = weatherData['timezone'];

    final sunrise = DateTime.fromMillisecondsSinceEpoch(sys['sunrise'] * 1000, isUtc: true)
        .toLocal();
    final sunset = DateTime.fromMillisecondsSinceEpoch(sys['sunset'] * 1000, isUtc: true)
        .toLocal();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin bổ sung',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDetailRow(Icons.wb_sunny, 'Mặt trời mọc', _formatTime(sunrise), Colors.orange),
            _buildDetailRow(Icons.nightlight_round, 'Mặt trời lặn', _formatTime(sunset), Colors.blue),
            _buildDetailRow(Icons.location_on, 'Múi giờ', 'UTC${_formatTimezone(timezone)}', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimezone(int timezoneSeconds) {
    final hours = timezoneSeconds ~/ 3600;
    final minutes = (timezoneSeconds % 3600) ~/ 60;
    return '${hours >= 0 ? '+' : ''}${hours}:${minutes.toString().padLeft(2, '0')}';
  }
}