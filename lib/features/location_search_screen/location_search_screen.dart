import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';

class LocationSearchScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  LocationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("WeatherNow Search"), 
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. THANH TÌM KIẾM
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Tìm thành phố của bạn...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    provider.searchCity(""); // Reset kết quả về rỗng
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (value) => provider.searchCity(value),
            ),
          ),

          // Hiệu ứng thanh chạy khi đang tải dữ liệu tìm kiếm
          if (provider.isLoading) const LinearProgressIndicator(),

          // 2. NỘI DUNG THAY ĐỔI (Lịch sử hoặc Kết quả)
          Expanded(
            child: provider.searchResults.isEmpty 
                ? _buildRecentSearches(provider) 
                : _buildSearchResults(provider),
          ),
        ],
      ),
    );
  }

  // Giao diện Lịch sử tìm kiếm (Khi chưa nhập hoặc kết quả rỗng)
  Widget _buildRecentSearches(LocationProvider provider) {
    if (provider.recentSearches.isEmpty) {
      return const Center(child: Text("Hãy nhập tên thành phố để tìm kiếm"));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TÌM KIẾM GẦN ĐÂY", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              TextButton(
                onPressed: () => provider.clearRecent(), 
                child: const Text("Xóa tất cả")
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.recentSearches.length,
            itemBuilder: (ctx, i) => ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(provider.recentSearches[i]),
              onTap: () {
                _controller.text = provider.recentSearches[i];
                provider.searchCity(provider.recentSearches[i]);
              },
            ),
          ),
        ),
      ],
    );
  }

  // Giao diện Kết quả trả về sau khi Search
  Widget _buildSearchResults(LocationProvider provider) {
    return ListView.builder(
      itemCount: provider.searchResults.length,
      itemBuilder: (ctx, i) {
        final loc = provider.searchResults[i];
        return ListTile(
          leading: const Icon(Icons.location_on, color: Colors.blue),
          title: Text(loc.name),
          subtitle: Text("${loc.country} ${loc.state ?? ''}"),
          // SỬA ONTAP: Đợi lấy dữ liệu thời tiết rồi mới hiện BottomSheet
          onTap: () async {
            // Hiển thị loading nhẹ trong khi đợi gọi API Weather
            showDialog(
              context: ctx,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );

            await provider.fetchWeather(loc.lat, loc.lon);
            
            Navigator.pop(ctx); // Đóng Loading Dialog
            _showWeatherBottomSheet(ctx, provider, loc.name);
          },
          trailing: _buildTrailingIcons(provider, loc),
        );
      },
    );
  }

  // Các nút tính năng (Tim và So sánh)
  Widget _buildTrailingIcons(LocationProvider provider, dynamic loc) {
    final isSaved = provider.savedLocations.any((e) => e.name == loc.name);
    final isComparing = provider.compareList.any((e) => e.name == loc.name);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(isComparing ? Icons.compare_arrows : Icons.compare_arrows_outlined, 
            color: Colors.orange),
          onPressed: () => provider.toggleCompare(loc),
        ),
        IconButton(
          icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border, 
            color: Colors.red),
          onPressed: () => provider.toggleFavorite(loc),
        ),
      ],
    );
  }

  // Bottom Sheet hiển thị thông tin thời tiết chi tiết (Màn 12 & 9)
  void _showWeatherBottomSheet(BuildContext context, LocationProvider provider, String cityName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))
      ),
      builder: (ctx) {
        final w = provider.currentWeather;
        if (w == null) {
          return const SizedBox(height: 150, child: Center(child: Text("Không có dữ liệu")));
        }
        
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.only(bottom: 20)),
              Text(cityName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),
              _buildInfoTile(Icons.thermostat, "Nhiệt độ", "${w['main']['temp']}°C", Colors.orange),
              _buildInfoTile(Icons.water_drop, "Độ ẩm", "${w['main']['humidity']}%", Colors.blue),
              _buildInfoTile(Icons.air, "Tốc độ gió", "${w['wind']['speed']} m/s", Colors.green),
              _buildInfoTile(Icons.cloud, "Trạng thái", "${w['weather'][0]['description']}", Colors.grey),
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