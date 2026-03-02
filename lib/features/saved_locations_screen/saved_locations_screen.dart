import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';

class SavedLocationsScreen extends StatelessWidget {
  const SavedLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);
    final savedItems = provider.savedLocations;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Địa điểm đã lưu"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: savedItems.isEmpty
          ? const Center(
              child: Text("Chưa có địa điểm nào được lưu.\nãy thả tim ở màn hình tìm kiếm!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            )
          : ReorderableListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              // Hàm xử lý kéo thả đã viết trong Provider
              onReorder: (oldIndex, newIndex) => provider.reorderSavedLocations(oldIndex, newIndex),
              children: [
                for (int index = 0; index < savedItems.length; index++)
                  ListTile(
                    key: ValueKey(savedItems[index].name), // Bắt buộc phải có Key để kéo thả
                    leading: const Icon(Icons.drag_handle, color: Colors.grey),
                    title: Text(savedItems[index].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(savedItems[index].country),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => provider.toggleFavorite(savedItems[index]),
                    ),
                    onTap: () {
                      // Tùng có thể code thêm: Ấn vào đây thì nhảy sang Màn 11 (Bản đồ)
                    },
                  ),
              ],
            ),
    );
  }
}