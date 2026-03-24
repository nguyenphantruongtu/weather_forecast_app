import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/location_provider.dart';
import '../../data/models/location_model.dart';
import '../location_search_screen/location_search_screen.dart';
import '../saved_locations_screen/saved_locations_screen.dart';
import '../map_view_screen/map_view_screen.dart';

class LocationCompareScreen extends StatefulWidget {
  const LocationCompareScreen({super.key});

  @override
  State<LocationCompareScreen> createState() => _LocationCompareScreenState();
}

class _LocationCompareScreenState extends State<LocationCompareScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _cityAData;
  Map<String, dynamic>? _cityBData;
  List<Map<String, dynamic>> _forecastDataA = [];
  List<Map<String, dynamic>> _forecastDataB = [];

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    final provider = Provider.of<LocationProvider>(context, listen: false);
    
    if (provider.compareList.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Lấy dữ liệu thời tiết cho thành phố A (gốc)
      final dataA = await provider.fetchWeatherData(
        provider.compareList[0].latitude, 
        provider.compareList[0].longitude
      );
      
      // Lấy dữ liệu thời tiết cho thành phố B (vừa tìm kiếm)
      Map<String, dynamic>? dataB;
      if (provider.compareList.length > 1) {
        dataB = await provider.fetchWeatherData(
          provider.compareList[1].latitude, 
          provider.compareList[1].longitude
        );
      }

      setState(() {
        _cityAData = dataA;
        _cityBData = dataB;
        _isLoading = false;
      });

      // Lấy dữ liệu dự báo nếu cần
      if (dataA != null) {
        _fetchForecastData(provider.compareList[0].latitude, provider.compareList[0].longitude, isCityA: true);
      }
      if (dataB != null) {
        _fetchForecastData(provider.compareList[1].latitude, provider.compareList[1].longitude, isCityA: false);
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lấy dữ liệu thời tiết: $e')),
      );
    }
  }

  Future<void> _fetchForecastData(double lat, double lon, {required bool isCityA}) async {
    try {
      // Gọi API dự báo OpenWeatherMap
      // TODO: Thay YOUR_API_KEY bằng API key thực tế của bạn
      final apiKey = '217b719f20e6ea5bdd5e3c45efd89d65';
      final url = 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> forecastList = data['list'];
        
        // Lấy 6 phần tử đầu tiên (6 mốc thời gian gần nhất)
        final List<Map<String, dynamic>> forecastData = [];
        for (int i = 0; i < 6 && i < forecastList.length; i++) {
          final item = forecastList[i];
          final dtTxt = item['dt_txt'] as String;
          final temp = item['main']['temp'] as double;
          
          // Parse giờ từ dt_txt (format: "2023-03-24 09:00:00")
          final time = dtTxt.split(' ')[1].substring(0, 5); // Lấy "09:00"
          
          forecastData.add({
            'time': time,
            'temp': temp,
          });
        }
        
        // Lưu vào state tương ứng
        if (isCityA) {
          _forecastDataA = forecastData;
        } else {
          _forecastDataB = forecastData;
        }
        
        setState(() {});
      } else {
        print('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi lấy dữ liệu dự báo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "So sánh thời tiết",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (context) => const LocationSearchScreen()));
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedLocationsScreen()));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (context) => const MapViewScreen()));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm kiếm"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Yêu thích"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Bản đồ"),
          BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: "So sánh"),
        ],
      ),
      body: provider.compareList.isEmpty
        ? const Center(child: Text("Chưa có địa điểm nào để so sánh"))
        : _isLoading
          ? _buildLoadingScreen()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Phần Tổng quan (Top Section)
                  _buildOverviewSection(provider),
                  const SizedBox(height: 24),
                  
                  // Phần Chỉ số chi tiết
                  _buildDetailsComparison(provider),
                  const SizedBox(height: 24),
                  
                  // Phần Biểu đồ Nhiệt độ
                  _buildTemperatureChart(provider),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 16),
          Text('Đang tải dữ liệu thời tiết...'),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(LocationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cột trái - Thành phố A (Gốc)
          Expanded(
            child: _buildCityCard(provider.compareList[0], isLeft: true, provider: provider, isCityA: true),
          ),
          
          const SizedBox(width: 16),
          
          // Cột phải - Thành phố B (Vừa tìm kiếm)
          if (provider.compareList.length > 1)
            Expanded(
              child: _buildCityCard(provider.compareList[1], isLeft: false, provider: provider, isCityA: false),
            ),
        ],
      ),
    );
  }

  Widget _buildCityCard(Location city, {required bool isLeft, required LocationProvider provider, required bool isCityA}) {
    final data = isCityA ? _cityAData : _cityBData;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLeft ? Colors.blue[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Nút xóa (thùng rác hoặc dấu X)
          Align(
            alignment: isLeft ? Alignment.topLeft : Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
              onPressed: () => provider.toggleCompare(city),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Tên thành phố
          Text(
            '${city.name}, ${city.country}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Icon thời tiết (sử dụng icon mặt trời cho đơn giản)
          const Icon(Icons.wb_sunny, size: 64, color: Colors.orange),
          
          const SizedBox(height: 8),
          
          // Nhiệt độ (từ API)
          Text(
            data != null 
              ? '${data['main']['temp'].round()}°C'
              : '--°C',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isLeft ? Colors.blue[800] : Colors.red[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsComparison(LocationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'CHI TIẾT SO SÁNH',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // Danh sách các chỉ số
          _buildDetailRow(Icons.thermostat, 'Cảm giác như', 
            _cityAData != null ? '${_cityAData!['main']['feels_like'].round()}°' : '--°', 
            _cityBData != null ? '${_cityBData!['main']['feels_like'].round()}°' : '--°'),
          
          _buildDetailRow(Icons.water_drop, 'Độ ẩm', 
            _cityAData != null ? '${_cityAData!['main']['humidity']}%' : '--%', 
            _cityBData != null ? '${_cityBData!['main']['humidity']}%' : '--%'),
          
          _buildDetailRow(Icons.air, 'Tốc độ gió', 
            _cityAData != null ? '${_cityAData!['wind']['speed'].toStringAsFixed(1)} m/s' : '-- m/s', 
            _cityBData != null ? '${_cityBData!['wind']['speed'].toStringAsFixed(1)} m/s' : '-- m/s'),
          
          _buildDetailRow(Icons.visibility, 'Tầm nhìn', 
            _cityAData != null ? '${(_cityAData!['visibility'] / 1000).toStringAsFixed(1)} km' : '-- km', 
            _cityBData != null ? '${(_cityBData!['visibility'] / 1000).toStringAsFixed(1)} km' : '-- km'),
          
          _buildDetailRow(Icons.cloud, 'Độ che phủ mây', 
            _cityAData != null ? '${_cityAData!['clouds']['all']}%' : '--%', 
            _cityBData != null ? '${_cityBData!['clouds']['all']}%' : '--%'),
          
          _buildDetailRow(Icons.compress, 'Áp suất', 
            _cityAData != null ? '${_cityAData!['main']['pressure']} hPa' : '-- hPa', 
            _cityBData != null ? '${_cityBData!['main']['pressure']} hPa' : '-- hPa'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String valueA, String valueB) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Trục trung tâm - Label
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Giá trị bên trái (Thành phố A)
          Expanded(
            flex: 1,
            child: Text(
              valueA,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          
          // Khoảng cách trung tâm
          const SizedBox(width: 16),
          
          // Giá trị bên phải (Thành phố B)
          Expanded(
            flex: 1,
            child: Text(
              valueB,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureChart(LocationProvider provider) {
    // Tính toán giới hạn trục Y động
    double minY = 15.0;
    double maxY = 35.0;
    
    if (_forecastDataA.isNotEmpty || _forecastDataB.isNotEmpty) {
      final allTemps = <double>[];
      allTemps.addAll(_forecastDataA.map((item) => item['temp'] as double));
      allTemps.addAll(_forecastDataB.map((item) => item['temp'] as double));
      
      if (allTemps.isNotEmpty) {
        final minTemp = allTemps.reduce((a, b) => a < b ? a : b);
        final maxTemp = allTemps.reduce((a, b) => a > b ? a : b);
        
        minY = minTemp - 2;
        maxY = maxTemp + 2;
      }
    }
    
    // Tính toán khoảng cách trục Y linh hoạt
    final double tempRange = maxY - minY;
    final double yAxisInterval = tempRange > 15 ? 5 : 2;
    
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'BIỂU ĐỒ NHIỆT ĐỘ TRONG NGÀY',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: _buildGridData(),
                titlesData: _buildTitlesData(yAxisInterval),
                borderData: _buildBorderData(),
                minX: 0,
                maxX: 5,
                minY: minY,
                maxY: maxY,
                lineBarsData: _buildLineBarsData(),
                lineTouchData: _buildLineTouchData(provider),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Chú thích màu
          _buildLegend(provider),
        ],
      ),
    );
  }

  // Hàm xây dựng dữ liệu lưới
  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 5,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey[300],
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Colors.grey[300],
          strokeWidth: 1,
        );
      },
    );
  }

  // Hàm xây dựng đường viền biểu đồ
  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: Colors.grey[200]!, width: 1),
    );
  }

  // Hàm xây dựng tiêu đề trục
  FlTitlesData _buildTitlesData(double yAxisInterval) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: _getBottomTitles,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: yAxisInterval,
          getTitlesWidget: _getLeftTitles,
        ),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  // Hàm lấy tiêu đề trục X (thời gian)
  Widget _getBottomTitles(double value, TitleMeta meta) {
    // Lấy thời gian từ dữ liệu thực tế thay vì hardcode
    String timeText = '';
    
    // Ưu tiên lấy từ dữ liệu thành phố A, nếu không có thì lấy từ thành phố B
    if (_forecastDataA.isNotEmpty && value < _forecastDataA.length) {
      timeText = _forecastDataA[value.toInt()]['time'] as String;
    } else if (_forecastDataB.isNotEmpty && value < _forecastDataB.length) {
      timeText = _forecastDataB[value.toInt()]['time'] as String;
    } else {
      // Fallback nếu không có dữ liệu
      final titles = <double, String>{
        0: '08:00',
        1: '11:00',
        2: '14:00',
        3: '17:00',
        4: '20:00',
        5: '23:00',
      };
      timeText = titles[value] ?? '';
    }
    
    return Text(
      timeText,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Hàm lấy tiêu đề trục Y (nhiệt độ)
  Widget _getLeftTitles(double value, TitleMeta meta) {
    return Text(
      '${value.toInt()}°',
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Hàm xây dựng dữ liệu đường biểu diễn
  List<LineChartBarData> _buildLineBarsData() {
    final List<LineChartBarData> lines = [];
    
    // Đường biểu diễn cho Thành phố A (Xanh dương)
    if (_forecastDataA.isNotEmpty) {
      lines.add(
        LineChartBarData(
          spots: _forecastDataA.asMap().entries.map((entry) => 
            FlSpot(entry.key.toDouble(), entry.value['temp'] as double)
          ).toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.1),
          ),
        ),
      );
    }
    
    // Đường biểu diễn cho Thành phố B (Đỏ)
    if (_forecastDataB.isNotEmpty) {
      lines.add(
        LineChartBarData(
          spots: _forecastDataB.asMap().entries.map((entry) => 
            FlSpot(entry.key.toDouble(), entry.value['temp'] as double)
          ).toList(),
          isCurved: true,
          color: Colors.red,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.red.withOpacity(0.1),
          ),
        ),
      );
    }
    
    return lines;
  }

  // Hàm xây dựng dữ liệu tương tác chạm
  LineTouchData _buildLineTouchData(LocationProvider provider) {
    return LineTouchData(
      enabled: true,
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipRoundedRadius: 8,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            // Xác định tên thành phố dựa trên index của đường biểu diễn
            String cityName = '';
            Color tooltipColor = Colors.blueGrey[800]!;
            
            // Kiểm tra xem điểm chạm thuộc đường nào
            if (touchedSpot.barIndex == 0 && _forecastDataA.isNotEmpty) {
              // Đường biểu diễn thành phố A
              cityName = provider.compareList[0].name;
              tooltipColor = Colors.blue;
            } else if (touchedSpot.barIndex == 1 && _forecastDataB.isNotEmpty) {
              // Đường biểu diễn thành phố B
              cityName = provider.compareList[1].name;
              tooltipColor = Colors.red;
            }
            
            return LineTooltipItem(
              '$cityName: ${touchedSpot.y.toStringAsFixed(1)}°',
              TextStyle(
                color: tooltipColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  // Hàm xây dựng chú thích màu
  Widget _buildLegend(LocationProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 12, color: Colors.blue),
            const SizedBox(width: 4),
            Text(provider.compareList[0].name, style: const TextStyle(fontSize: 12, color: Colors.blue)),
          ],
        ),
        if (provider.compareList.length > 1) ...[
          const SizedBox(width: 24),
          Row(
            children: [
              Icon(Icons.circle, size: 12, color: Colors.red),
              const SizedBox(width: 4),
              Text(provider.compareList[1].name, style: const TextStyle(fontSize: 12, color: Colors.red)),
            ],
          ),
        ],
      ],
    );
  }
}