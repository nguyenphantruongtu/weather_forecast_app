import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Bản đồ địa điểm đã lưu")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(21.02, 105.83), // Mặc định ở Việt Nam
          zoom: 5,
        ),
        // Lấy danh sách ghim từ Provider
        markers: provider.mapMarkers,
        myLocationEnabled: true,
        mapType: MapType.normal,
      ),
    );
  }
}