import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/weather_provider.dart';
import '../../data/models/weather_model.dart';

class CompareLocationsScreen extends StatefulWidget {
  const CompareLocationsScreen({super.key});

  @override
  State<CompareLocationsScreen> createState() => _CompareLocationsScreenState();
}

class _CompareLocationsScreenState extends State<CompareLocationsScreen> {
  bool _isSideBySide = true;
  List<Map<String, dynamic>> _selectedLocations = [];
  List<Map<String, dynamic>> _compareData = [];

  IconData _getIconData(String description) {
    switch (description.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.cloud;
    }
  }

  void _updateDataFromProvider(List<WeatherModel> locations) {
    if (locations.isEmpty) {
      _selectedLocations = [];
      _compareData = [];
      return;
    }

    _selectedLocations = locations.map((w) {
      final parts = w.location.split(',');
      return {
        'name': parts.first,
        'country': parts.length > 1 ? parts.last.trim() : '',
        'weatherIcon': _getIconData(w.description),
        'temperature': '${w.temperature.round()}°',
        'fullName': w.location,
      };
    }).toList();

    if (locations.length >= 2) {
      final w1 = locations[0];
      final w2 = locations[1];
      _compareData = [
        {'metric': 'Current', 'v1': '${w1.temperature.round()}°', 'v2': '${w2.temperature.round()}°'},
        {'metric': 'Feels Like', 'v1': '${w1.feelsLike.round()}°', 'v2': '${w2.feelsLike.round()}°'},
        {'metric': 'Weather', 'v1': w1.description, 'v2': w2.description},
        {'metric': 'Humidity', 'v1': '${w1.humidity}%', 'v2': '${w2.humidity}%'},
        {'metric': 'Wind Speed', 'v1': '${w1.windSpeed} km/h', 'v2': '${w2.windSpeed} km/h'},
        {'metric': 'UV Index', 'v1': w1.uvIndex.toString(), 'v2': w2.uvIndex.toString()},
      ];
    } else if (locations.length == 1) {
      final w1 = locations[0];
      _compareData = [
        {'metric': 'Current', 'v1': '${w1.temperature.round()}°', 'v2': '-'},
        {'metric': 'Feels Like', 'v1': '${w1.feelsLike.round()}°', 'v2': '-'},
        {'metric': 'Weather', 'v1': w1.description, 'v2': '-'},
        {'metric': 'Humidity', 'v1': '${w1.humidity}%', 'v2': '-'},
        {'metric': 'Wind Speed', 'v1': '${w1.windSpeed} km/h', 'v2': '-'},
        {'metric': 'UV Index', 'v1': w1.uvIndex.toString(), 'v2': '-'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final locations = provider.compareLocations;

    _updateDataFromProvider(locations);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Compare Locations',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Selected locations row
            _buildSelectedLocationsRow(),

            const SizedBox(height: 16),

            // Toggle menu
            _buildToggleMenu(),

            const SizedBox(height: 24),

            // Comparison table
            Expanded(
              child: SingleChildScrollView(
                child: _isSideBySide 
                  ? _buildSideBySideTable()
                  : _buildChartsView(locations),
              ),
            ),

            const SizedBox(height: 16),

            // Quick stats
            _buildQuickStats(locations),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedLocationsRow() {
    return Container(
      height: 120, // Tăng thêm height để an toàn tuyệt đối
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedLocations.length + 1, // +1 for add button
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == _selectedLocations.length) {
            // Add button
            return Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vào màn hình Tìm Kiếm để thêm thành phố!')),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.grey),
                  label: const Text(
                    'Add',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            );
          }

          final location = _selectedLocations[index];
          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            location['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location['country'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            location['weatherIcon'],
                            size: 24,
                            color: const Color(0xFF2D88FF),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            location['temperature'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ),
                
                // Remove badge
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () {
                      context.read<WeatherProvider>().removeCityFromCompare(location['fullName']);
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleMenu() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isSideBySide = true;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: _isSideBySide ? const Color(0xFF2D88FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Side by Side',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isSideBySide = false;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: !_isSideBySide ? const Color(0xFF2D88FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Charts',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBySideTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header row
            CompareTableRow(
              metric: 'Metric',
              value1: _selectedLocations.isNotEmpty ? _selectedLocations[0]['name'] : 'City 1',
              value2: _selectedLocations.length > 1 ? _selectedLocations[1]['name'] : 'City 2',
              isHeader: true,
            ),
            
            // Data rows
            for (var data in _compareData)
              CompareTableRow(
                metric: data['metric'],
                value1: data['v1'],
                value2: data['v2'],
                isHeader: false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsView(List<WeatherModel> locations) {
    if (locations.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No data to compare charts')),
        ),
      );
    }

    return Column(
      children: [
        _buildComparisonChart(
          title: 'Temperature (°C)',
          locations: locations,
          getValue: (w) => w.temperature,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildComparisonChart(
          title: 'Humidity (%)',
          locations: locations,
          getValue: (w) => w.humidity.toDouble(),
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildComparisonChart(
          title: 'Wind Speed (km/h)',
          locations: locations,
          getValue: (w) => w.windSpeed,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildComparisonChart({
    required String title,
    required List<WeatherModel> locations,
    required double Function(WeatherModel) getValue,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: locations.fold<double>(0, (max, w) {
                    double val = getValue(w);
                    return val > max ? val : max;
                  }) * 1.2,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= locations.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              locations[index].location.split(',').first,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(locations.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: getValue(locations[index]),
                          color: index == 0 ? color : color.withOpacity(0.6),
                          width: 30,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 0,
                            color: Colors.grey[100],
                          ),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(List<WeatherModel> locations) {
    if (locations.isEmpty) return const SizedBox();

    WeatherModel warmest = locations[0];
    if (locations.length > 1 && locations[1].temperature > locations[0].temperature) {
      warmest = locations[1];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.whatshot, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Warmest Location',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                warmest.location.split(',').first,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${warmest.temperature.round()}°',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class CompareTableRow extends StatelessWidget {
  final String metric;
  final String value1;
  final String value2;
  final bool isHeader;

  const CompareTableRow({
    super.key,
    required this.metric,
    required this.value1,
    required this.value2,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isHeader ? Colors.transparent : Colors.grey[200]!,
            width: isHeader ? 0 : 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              metric,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? Colors.grey[600] : Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? Colors.grey[600] : Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? Colors.grey[600] : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}