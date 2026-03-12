# 📱 Hướng Dẫn Flutter/Dart Cho Người Mới Bắt Đầu

## 🎯 Giới Thiệu Chung

Dự án này là một ứng dụng thời tiết với 4 màn hình chính được sắp xếp trong cấu trúc **MVC + Provider Pattern**:

```
lib/
├── main.dart              # Entry point - bắt đầu ứng dụng
├── app.dart               # Root widget - cấu hình theme & routing
├── screens/               # Các màn hình UI
├── providers/             # Quản lý trạng thái (State Management)
├── data/models/           # Mô hình dữ liệu
└── widgets/common/        # Các widget tái sử dụng
```

---

## 🔧 **Component 1: Main Entry Point**

### 📄 `lib/main.dart`

```dart
void main() async {
  // Đảm bảo tất cả plugin native được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Tải file .env (chứa API keys, secrets)
  await dotenv.load();
  
  // Khởi tạo và tải cài đặt từ SharedPreferences (local storage)
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();
  
  // Chạy app với MultiProvider
  runApp(MultiProvider(...));
}
```

**Giải thích:**
- `main()` là hàm đầu tiên được gọi khi app khởi động
- `WidgetsFlutterBinding.ensureInitialized()`: Chuẩn bị Flutter engine
- `dotenv.load()`: Tải biến environment từ `.env` file
- `MultiProvider`: Cung cấp nhiều "provider" (quản lý trạng thái) cho toàn bộ app

---

### 📄 `lib/app.dart`

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // context.watch: theo dõi SettingsProvider, rebuild khi thay đổi
    final settingsProvider = context.watch<SettingsProvider>();
    
    return MaterialApp(
      theme: ThemeProvider.getTheme(settingsProvider.settings.theme),
      home: const SplashScreen(),
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/location_setup': (_) => const LocationSetupScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/info': (_) => const InfoScreen(),
      },
    );
  }
}
```

**Giải thích:**
- `StatelessWidget`: Widget không có trạng thái thay đổi
- `context.watch<SettingsProvider>()`: Theo dõi provider, rebuild khi settings thay đổi
- `routes`: Bản đồ điều hướng (navigation) giữa các màn hình

---

## 🎨 **Component 2: Provider & State Management**

### 📄 `lib/providers/settings_provider.dart`

```dart
class SettingsProvider extends ChangeNotifier {
  SettingsModel _settings = SettingsModel();
  late SharedPreferences _prefs;
  
  // Getter: lấy settings hiện tại
  SettingsModel get settings => _settings;
  
  // Khởi tạo: tải cài đặt từ SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }
  
  // Cập nhật: thay đổi setting + lưu + thông báo listeners
  void updateTemperatureUnit(TemperatureUnit unit) {
    _settings.temperatureUnit = unit;
    _prefs.setString('temperatureUnit', ...);
    notifyListeners(); // Báo tất cả listeners: "Hey, dữ liệu thay đổi rồi!"
  }
}
```

**Giải thích:**
- `ChangeNotifier`: Class cơ sở cho state management
- `notifyListeners()`: Thông báo cho tất cả widget đang theo dõi provider này
- `SharedPreferences`: Local storage (lưu dữ liệu vào device)
- **Flow**: Người dùng thay đổi setting → `updateTemperatureUnit()` → `_prefs.setString()` → `notifyListeners()` → Widget rebuild

---

### 📄 `lib/data/models/settings_model.dart`

```dart
enum TemperatureUnit { celsius, fahrenheit }  // Các tùy chọn nhiệt độ
enum WindSpeedUnit { kmh, mph }               // Các tùy chọn tốc độ gió
enum AppTheme { light, dark }                 // Theme
enum TimeFormat { h12, h24 }                  // Định dạng giờ

class SettingsModel {
  TemperatureUnit temperatureUnit;
  WindSpeedUnit windSpeedUnit;
  AppTheme theme;
  TimeFormat timeFormat;
  String language;
  
  // Constructor với giá trị mặc định
  SettingsModel({
    this.temperatureUnit = TemperatureUnit.celsius,
    this.windSpeedUnit = WindSpeedUnit.kmh,
    this.theme = AppTheme.light,
    this.timeFormat = TimeFormat.h24,
    this.language = 'en',
  });
}
```

**Giải thích:**
- `enum`: Tạo một tập hợp các giá trị cố định (VD: chỉ có `celsius` hoặc `fahrenheit`)
- `SettingsModel`: "Mô hình" lưu trữ tất cả cài đặt
- Constructor với giá trị mặc định: Nếu người dùng không set, sẽ dùng giá trị mặc định

---

## 🎬 **Component 3: Các Màn Hình (Screens)**

### **Màn 1: Splash Screen** 🌟

**Các file:**
- `splash_screen.dart`: Widget chính hiển thị logo + animation
- `splash_animation.dart`: Animation phóng to logo

```dart
// splash_screen.dart
class SplashScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    // Sau 3 giây, chuyển sang Onboarding
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) { // Kiểm tra widget còn trong tree không
        Navigator.pushReplacement(...); // Chuyển sang màn mới
      }
    });
  }
}
```

**Giải thích:**
- `StatefulWidget`: Widget có state (trạng thái) thay đổi
- `Future.delayed()`: Đợi 3 giây rồi thực hiện action
- `mounted`: Biến boolean kiểm tra widget có còn hoạt động không
- `Navigator.pushReplacement()`: Chuyển sang màn mới và xóa splash khỏi "back stack"

```dart
// splash_animation.dart - ScaleTransition
class _SplashAnimationState extends State<SplashAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    // Tạo animation: 0.8 → 1.0 (phóng to)
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticInOut, // Kiểu animation (co giãn)
      ),
    );
    
    _animationController.forward(); // Bắt đầu animation
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaleTransition( // Widget animation phóng to/nhỏ
      scale: _animation,
      child: Logo(),
    );
  }
}
```

**Giải thích:**
- `AnimationController`: Điều khiển animation (bắt đầu, dừng, v.v.)
- `Tween<double>(begin: 0.8, end: 1.0)`: Giá trị từ 0.8 (80%) đến 1.0 (100%)
- `CurvedAnimation`: Thêm "easing" (đường cong) để animation mượt mà
- `ScaleTransition`: Widget để phóng to/nhỏ dựa trên animation value

---

### **Màn 2: Onboarding Screen** 📖

**Các file:**
- `onboarding_screen.dart`: Màn chính với PageView
- `onboarding_page.dart`: Widget cho mỗi slide
- `page_indicator.dart`: Các chấm chỉ thị trang

```dart
// onboarding_screen.dart
class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<OnboardingPage> pages;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // PageView: Cho phép swipe giữa các trang
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index); // Update UI
              },
              itemBuilder: (context, index) {
                return OnboardingPageWidget(page: pages[index]);
              },
            ),
          ),
          // Chấm chỉ thị trang
          PageIndicator(
            totalPages: pages.length,
            currentPage: _currentPage,
          ),
          // Nút Next/Start
          ElevatedButton(...)
        ],
      ),
    );
  }
}
```

**Giải thích:**
- `PageController`: Điều khiển PageView (chuyển trang, v.v.)
- `PageView.builder`: Tạo các trang động (hiệu suất tốt)
- `onPageChanged`: Callback khi người dùng swipe tới trang mới
- `setState(() => ...)`: Cập nhật UI khi state thay đổi
- `Expanded`: Chiếm tất cả không gian còn lại

```dart
// onboarding_page.dart
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(page.image), // Ảnh slide
        Text(page.title),        // Tiêu đề
        Text(page.description),  // Mô tả
      ],
    );
  }
}
```

**Giải thích:**
- `mainAxisAlignment.center`: Căn giữa các widget theo chiều dọc
- `Image.asset()`: Load ảnh từ project (thường trong `assets/`)
- `Text()`: Hiển thị text

```dart
// page_indicator.dart - Các chấm chỉ thị
class PageIndicator extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          width: index == currentPage ? 12 : 8, // Chấm hiện tại to hơn
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentPage ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }
}
```

**Giải thích:**
- `List.generate(count, (index) => ...)`: Tạo list với số lượng xác định
- Ternary operator `? :`: `condition ? valueIfTrue : valueIfFalse`

---

### **Màn 3: Location Setup Screen** 📍

**Các file:**
- `location_setup_screen.dart`: Màn chính
- `location_option_card.dart`: Card cho mỗi lựa chọn vị trí
- `permission_dialog.dart`: Dialog xin quyền GPS

```dart
// location_setup_screen.dart
class _LocationSetupScreenState extends State<LocationSetupScreen> {
  String? _selectedCity;
  
  Future<void> _getCurrentLocation() async {
    // Kiểm tra quyền
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Hiển thị dialog xin quyền
      bool? allowed = await PermissionDialog.show(...);
      if (allowed != true) return; // Người dùng từ chối
    }
    
    // Lấy vị trí hiện tại
    Position position = await Geolocator.getCurrentPosition();
    
    // Chuyển đổi tọa độ thành tên thành phố
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    
    setState(() => _selectedCity = cityName);
  }
}
```

**Giải thích:**
- `Geolocator`: Plugin lấy vị trí GPS
- `LocationPermission`: Enum kiểm soát quyền truy cập GPS
- `Position`: Tọa độ (latitude, longitude)
- `placemarkFromCoordinates()`: Chuyển tọa độ thành địa chỉ (reverse geocoding)
- `await`: Đợi action bất đồng bộ hoàn thành

```dart
// location_option_card.dart
class LocationOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Callback khi nhấn
      child: Card(
        child: Column(
          children: [
            Icon(icon),
            Text(title),
            Text(description),
          ],
        ),
      ),
    );
  }
}
```

**Giải thích:**
- `GestureDetector`: Bắt sự kiện gesture (tap, long press, v.v.)
- `Card`: Widget hiển thị nội dung với shadow
- `Icon()`: Hiển thị biểu tượng từ Material Icons
- `VoidCallback`: Kiểu dữ liệu cho hàm không param, không return

```dart
// permission_dialog.dart
class PermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onDeny,
          child: const Text('Deny'),
        ),
        ElevatedButton(
          onPressed: onAllow,
          child: const Text('Allow'),
        ),
      ],
    );
  }
  
  // Static method để hiển thị dialog
  static Future<bool?> show(BuildContext context, ...) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Không thể tap ngoài dialog
      builder: (context) => PermissionDialog(...),
    );
  }
}
```

**Giải thích:**
- `AlertDialog`: Dialog chuẩn Material Design
- `actions`: Danh sách nút ở dưới dialog
- `showDialog<bool>()`: Hiển thị dialog, trả về Future<bool>
- `static`: Phương thức thuộc class, không cần instance

---

### **Màn 4: Settings Screen** ⚙️

**Các file:**
- `settings_screen.dart`: Màn chính
- `setting_tile.dart`: Widget row cài đặt
- `unit_selector.dart`: Dialog chọn đơn vị

```dart
// settings_screen.dart
class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // context.watch: rebuild khi SettingsProvider thay đổi
    final settingsProvider = context.watch<SettingsProvider>();
    
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          SettingTile(
            title: 'Temperature Unit',
            subtitle: settingsProvider.settings.temperatureUnit == 
                      TemperatureUnit.celsius ? '°C' : '°F',
            icon: Icons.thermostat,
            onTap: () => _showTemperatureUnitSelector(context),
          ),
          ToggleSettingTile(
            title: 'Dark Mode',
            value: settingsProvider.settings.theme == AppTheme.dark,
            onChanged: (value) {
              settingsProvider.updateTheme(
                value ? AppTheme.dark : AppTheme.light,
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showTemperatureUnitSelector(BuildContext context) {
    final provider = context.read<SettingsProvider>();
    // context.read: lấy provider một lần, không theo dõi
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Temperature Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: Text('Celsius (°C)'),
              value: true,
              groupValue: provider.settings.temperatureUnit == 
                          TemperatureUnit.celsius,
              onChanged: (_) {
                provider.updateTemperatureUnit(TemperatureUnit.celsius);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

**Giải thích:**
- `ListView`: List dọc, có thể scroll
- `SettingTile`: Custom widget cho một dòng cài đặt
- `context.watch()` vs `context.read()`:
  - `watch()`: Theo dõi, rebuild khi thay đổi
  - `read()`: Chỉ lấy một lần, không rebuild
- `RadioListTile`: ListTile với Radio button
- `showDialog()`: Hiển thị dialog

```dart
// setting_tile.dart
class SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon), // Biểu tượng ở bên trái
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios), // Mũi tên phải
      onTap: onTap,
    );
  }
}

class ToggleSettingTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged; // Callback với giá trị
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
```

**Giải thích:**
- `ListTile`: Widget chuẩn cho một dòng content (leading, title, trailing)
- `Switch`: Widget toggle on/off
- `ValueChanged<T>`: Kiểu dữ liệu cho hàm nhận một param

---

### **Màn 5: Info Screen** ℹ️

**Các file:**
- `info_screen.dart`: Màn chính
- `faq_item.dart`: Widget mở rộng FAQ
- `about_section.dart`: Section thông tin

```dart
// info_screen.dart
class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // About section
            AboutSection(
              icon: Icons.info,
              title: 'WeatherNow',
              content: 'Version 1.0.0\n...',
            ),
            
            // FAQ
            FAQItem(
              question: 'How to set location?',
              answer: 'Go to Settings and...',
            ),
            
            // Actions
            ElevatedButton.icon(
              onPressed: _rateApp,
              icon: Icon(Icons.star),
              label: Text('Rate App'),
            ),
            ElevatedButton.icon(
              onPressed: _shareApp,
              icon: Icon(Icons.share),
              label: Text('Share App'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _rateApp() async {
    const url = 'https://play.google.com/store/apps/details?id=...';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url)); // Mở URL
    }
  }
  
  Future<void> _shareApp() async {
    await Share.share('Check out this app!'); // Popup chia sẻ
  }
}
```

**Giải thích:**
- `SingleChildScrollView`: Cho phép scroll khi content vượt quá màn hình
- `launchUrl()`: Mở URL trong browser hoặc app store
- `Share.share()`: Popup chia sẻ content

```dart
// faq_item.dart - ExpansionTile
class FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  
  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question), // Click để mở/gấp
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer),
        ),
      ],
    );
  }
}
```

**Giải thích:**
- `ExpansionTile`: Tile có thể mở rộng/gấp lại
- `children`: Widget hiển thị khi mở rộng

---

## 📊 **Provider Pattern Hoạt Động**

```
┌─────────────────────────────────────────────────┐
│ main.dart (Entry Point)                         │
│  ↓ Khởi tạo SettingsProvider                   │
│  ↓ Wrap MyApp với MultiProvider                 │
└─────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────┐
│ app.dart (MyApp)                                │
│  ↓ context.watch<SettingsProvider>()           │
│  ↓ Rebuild nếu settings thay đổi               │
└─────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────┐
│ screens/settings_screen.dart                    │
│  ↓ Người dùng ấn "Dark Mode"                   │
│  ↓ provider.updateTheme(AppTheme.dark)         │
│  ↓ notifyListeners() được gọi                  │
└─────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────┐
│ Tất cả widget watch(SettingsProvider) rebuild   │
│ MyApp → ThemeProvider.getTheme() → apply theme  │
└─────────────────────────────────────────────────┘
```

---

## 🚀 **Chạy Ứng Dụng**

```bash
# 1. Cài đặt dependencies
flutter pub get

# 2. Chạy ứng dụng
flutter run

# 3. Hot reload (để cập nhật code nhanh)
# - Nhấn 'r' trong terminal
# - Hoặc Ctrl+S (VS Code) / Cmd+S (Mac)
```

---

## 💡 **Các Khái Niệm Quan Trọng**

| Khái Niệm | Giải Thích |
|-----------|-----------|
| **Widget** | Một phần UI (Button, Text, Image, v.v.) |
| **StatelessWidget** | Widget không thay đổi |
| **StatefulWidget** | Widget có state (dữ liệu) thay đổi |
| **build()** | Hàm tạo UI, được gọi lại khi state thay đổi |
| **setState()** | Báo Flutter: "Dữ liệu thay đổi, rebuild UI" |
| **Provider** | Quản lý trạng thái toàn ứng dụng |
| **context.watch()** | Theo dõi provider, rebuild khi thay đổi |
| **context.read()** | Lấy provider một lần, không theo dõi |
| **Navigator** | Điều hướng giữa các màn hình |
| **Future** | Một giá trị sẽ có sẵn ở tương lai |
| **async/await** | Cú pháp để làm việc với Future |

---

## 🎓 **Tiếp Theo**

1. Tạo các ảnh onboarding: `assets/images/onboarding/`
2. Kiểm tra permission GPS trên Android/iOS
3. Kết nối API thời tiết thực
4. Thêm animation mượt mà hơn
5. Viết unit tests

---

**Chúc bạn học tập vui vẻ! 🚀**
