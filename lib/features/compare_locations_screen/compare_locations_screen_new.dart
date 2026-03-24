import 'package:flutter/material.dart';

class CompareLocationsScreenNew extends StatefulWidget {
  const CompareLocationsScreenNew({super.key});

  @override
  State<CompareLocationsScreenNew> createState() => _CompareLocationsScreenNewState();
}

class _CompareLocationsScreenNewState extends State<CompareLocationsScreenNew> {
  bool _isSideBySide = true;
  List<Map<String, dynamic>> _selectedLocations = [
    {
      'name': 'Ho Chi Minh City',
      'country': 'Vietnam',
      'weatherIcon': Icons.wb_sunny,
      'temperature': '28°',
    },
    {
      'name': 'Hanoi',
      'country': 'Vietnam',
      'weatherIcon': Icons.cloud,
      'temperature': '25°',
    },
  ];

  List<Map<String, dynamic>> _compareData = [
    {'metric': 'Current', 'hcm': '28°', 'hanoi': '25°'},
    {'metric': 'Feels Like', 'hcm': '30°', 'hanoi': '27°'},
    {'metric': 'High / Low', 'hcm': '32° / 24°', 'hanoi': '28° / 22°'},
    {'metric': 'Weather', 'hcm': 'Sunny', 'hanoi': 'Cloudy'},
    {'metric': 'Humidity', 'hcm': '65%', 'hanoi': '75%'},
    {'metric': 'Precipitation', 'hcm': '0%', 'hanoi': '10%'},
    {'metric': 'Wind Speed', 'hcm': '12 km/h', 'hanoi': '15 km/h'},
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
          'Compare Locations',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // Add location to compare
            },
          ),
        ],
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
                  : _buildChartsView(),
              ),
            ),

            const SizedBox(height: 16),

            // Quick stats
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedLocationsRow() {
    return Container(
      height: 80,
              child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedLocations.length + 1, // +1 for add button
        separatorBuilder: (context, index) => SizedBox(width: 12),
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
                    // Add new location
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const Spacer(),
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
                
                // Remove badge
                Positioned(
                  top: 4,
                  right: 4,
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
              value1: _selectedLocations[0]['name'],
              value2: _selectedLocations[1]['name'],
              isHeader: true,
            ),
            
            // Data rows
            for (var data in _compareData)
              CompareTableRow(
                metric: data['metric'],
                value1: data['hcm'],
                value2: data['hanoi'],
                isHeader: false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsView() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Charts View Coming Soon',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This section will display visual charts comparing the selected locations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 131, 130, 130),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
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
          Icon(Icons.whatshot, color: Colors.red, size: 24),
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
                'Ho Chi Minh City',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '28°',
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