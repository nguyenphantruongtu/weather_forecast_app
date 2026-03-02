import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';

class LocationCompareScreen extends StatelessWidget {
  const LocationCompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);
    final items = provider.compareList;

    return Scaffold(
      appBar: AppBar(title: const Text("So sánh thời tiết")),
      body: items.isEmpty
          ? const Center(child: Text("Chọn địa điểm để so sánh"))
          : Row(
              children: items.map((loc) => Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.shade300))
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(loc.country, style: const TextStyle(color: Colors.grey)),
                        const Divider(),
                        // Các dòng thông số so sánh
                        _buildCompareRow(Icons.thermostat, "25°C", "Nhiệt độ"),
                        _buildCompareRow(Icons.water_drop, "80%", "Độ ẩm"),
                        _buildCompareRow(Icons.air, "12km/h", "Gió"),
                        _buildCompareRow(Icons.cloud, "U ám", "Trạng thái"),
                      ],
                    ),
                  ),
                ),
              )).toList(),
            ),
    );
  }

  Widget _buildCompareRow(IconData icon, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}