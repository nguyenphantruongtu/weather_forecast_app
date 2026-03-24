import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../data/models/location_model.dart';
import '../saved_locations_screen/saved_locations_screen.dart';
import '../map_view_screen/map_view_screen.dart';
import '../location_compare_screen/location_compare_screen.dart';
import '../weather_detail_screen/weather_detail_screen.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    final provider = Provider.of<LocationProvider>(context, listen: false);
    if (_controller.text.isNotEmpty) {
      // Khi gõ: Gọi API lấy gợi ý (không lưu vào history)
      provider.searchCityWithoutHistory(_controller.text);
    } else {
      // Khi xóa hết: Xóa kết quả gợi ý để quay về hiện lịch sử
      provider.searchCityWithoutHistory("");
    }
    setState(() {}); // Rebuild để cập nhật icon Clear
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("WeatherNow Search"),
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedLocationsScreen()));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (context) => const MapViewScreen()));
          if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (context) => const LocationCompareScreen()));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm kiếm"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Yêu thích"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Bản đồ"),
          BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: "So sánh"),
        ],
      ),
      body: Column(
        children: [
          // 1. THANH TÌM KIẾM
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: "Tìm thành phố của bạn...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _controller.clear()) 
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  provider.searchCity(value);
                  _focusNode.unfocus();
                }
              },
            ),
          ),

          if (provider.isLoading) const LinearProgressIndicator(),

          // 2. NỘI DUNG HIỂN THỊ
          Expanded(
            child: _buildSearchContent(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent(LocationProvider provider) {
    // KỊCH BẢN A: Ô nhập TRỐNG -> Hiện lịch sử tìm kiếm
    if (_controller.text.isEmpty) {
      if (provider.recentSearches.isNotEmpty) {
        return _buildHistoryList(provider);
      }
      return const Center(child: Text("Hãy nhập tên thành phố để tìm kiếm"));
    }

    // KỊCH BẢN B: Ô nhập CÓ CHỮ -> Hiện gợi ý từ API
    if (provider.searchResults.isNotEmpty) {
      return _buildResultsList(provider);
    }

    // Trường hợp đang gõ nhưng chưa có kết quả
    return provider.isLoading 
      ? const SizedBox.shrink() 
      : const Center(child: Text("Không tìm thấy kết quả phù hợp"));
  }

  // Giao diện Lịch sử (Chỉ hiện khi text rỗng)
  Widget _buildHistoryList(LocationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TÌM KIẾM GẦN ĐÂY", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
                _focusNode.unfocus();
              },
            ),
          ),
        ),
      ],
    );
  }

  // Giao diện Gợi ý/Kết quả (Hiện khi đang gõ)
  Widget _buildResultsList(LocationProvider provider) {
    return ListView.builder(
      itemCount: provider.searchResults.length,
      itemBuilder: (ctx, i) {
        final loc = provider.searchResults[i];
        return ListTile(
          leading: const Icon(Icons.location_on, color: Colors.blue),
          title: Text(loc.country), // Hiển thị tên quốc gia thay vì tên thành phố
          subtitle: Text("${loc.name} ${loc.state ?? ''}"), // Hiển thị tên thành phố trong subtitle
          onTap: () {
            // Khi chọn 1 gợi ý -> Gọi API thời tiết và hiển thị thông tin
            _fetchAndShowWeather(loc);
            _focusNode.unfocus();
          },
          trailing: _buildTrailingIcons(provider, loc),
        );
      },
    );
  }

  Widget _buildTrailingIcons(LocationProvider provider, Location loc) {
    final isSaved = provider.savedLocations.any((e) => e.id == loc.id);
    final isComparing = provider.compareList.any((e) => e.id == loc.id);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(isComparing ? Icons.compare_arrows : Icons.compare_arrows_outlined, color: Colors.orange),
          onPressed: () => provider.toggleCompare(loc),
        ),
        IconButton(
          icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border, color: Colors.red),
          onPressed: () => provider.toggleFavorite(loc),
        ),
      ],
    );
  }

  // Hàm mới: Gọi API thời tiết và hiển thị thông tin
  Future<void> _fetchAndShowWeather(Location loc) async {
    final provider = Provider.of<LocationProvider>(context, listen: false);
    
    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Gọi API thời tiết
      await provider.fetchWeather(loc.latitude, loc.longitude);
      
      // Đóng loading
      Navigator.pop(context);
      
      // Điều hướng đến WeatherDetailScreen để hiển thị thông tin chi tiết
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherDetailScreen(location: loc),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lấy thời tiết: $e')),
      );
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