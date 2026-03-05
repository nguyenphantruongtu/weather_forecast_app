# 📋 HƯỚNG DẪN CẤUTRÚC & SỬ DỤNG APP

## 1️⃣ **Cấu Trúc Project**

```
weather_forecast_app/
├── lib/
│   ├── main.dart                          # Entry point - MultiProvider setup
│   ├── app.dart                          # Root widget - Routing & theme
│   │
│   ├── screens/OnboardingAndUserPreferencesScreens/
│   │   ├── splash_screen/
│   │   │   ├── splash_screen.dart        # 3-second intro animation
│   │   │   └── splash_animation.dart     # ScaleTransition widget
│   │   │
│   │   ├── onboarding_screen/
│   │   │   ├── onboarding_screen.dart    # PageView container
│   │   │   └── widgets/
│   │   │       ├── onboarding_page.dart  # Individual slide
│   │   │       └── page_indicator.dart   # Dot indicator
│   │   │
│   │   ├── location_setup_screen/
│   │   │   ├── location_setup_screen.dart # GPS + search + cities
│   │   │   └── widgets/
│   │   │       ├── location_option_card.dart   # Card widget
│   │   │       └── permission_dialog.dart      # Dialog widget
│   │   │
│   │   ├── settings_screen/
│   │   │   ├── settings_screen.dart      # Settings interface
│   │   │   └── widgets/
│   │   │       ├── setting_tile.dart     # Setting row
│   │   │       └── unit_selector.dart    # Unit selection dialog
│   │   │
│   │   └── info_screen/
│   │       ├── info_screen.dart          # About, FAQ, Privacy, etc.
│   │       └── widgets/
│   │           ├── faq_item.dart         # Expandable FAQ
│   │           └── about_section.dart    # Info section
│   │
│   ├── providers/
│   │   ├── settings_provider.dart        # State management + SharedPreferences
│   │   └── theme_provider.dart           # Theme logic (light/dark)
│   │
│   └── data/
│       └── models/
│           └── settings_model.dart       # Data model & enums
│
├── assets/                               # ✨ NEW - Tất cả thư mục tạo sẵn
│   ├── images/
│   │   ├── logo/                  # App logo
│   │   ├── onboarding/            # 4 slide images
│   │   ├── weather_icons/         # Weather icons
│   │   └── illustrations/         # UI illustrations
│   ├── lottie/                    # Animations
│   └── data/                      # Static data
│
├── .env                           # ✨ NEW - Environment variables
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 2️⃣ **Luồng Ứng Dụng (App Flow)**

```
main.dart (Entry Point)
    ↓
MultiProvider Setup (SettingsProvider)
    ↓
app.dart (MyApp Root)
    ↓
Splash Screen (3 giây animation)
    ↓
    ├─→ Onboarding Screen (4 slides) → Xong → Save state
    │
    ├─→ Location Setup Screen → Chọn vị trí → Lưu GPS
    │
    ├─→ Settings Screen → Chỉnh settings → SharedPreferences
    │
    └─→ Info Screen → Xem thông tin → Share/Rate/FAQ
```

---

## 3️⃣ **Các Tính Năng Chính**

### **Splash Screen** 
- ⏱️ **Thời gian:** 3 giây
- 🎨 **Animation:** Cloud icon với scale animation
- 🔄 **Sau khi xong:** Tự động navigation tới Onboarding

### **Onboarding Screen**
- 📄 **Số slides:** 4
- 🎯 **Nội dung:**
  1. Real-time Weather (☁️‍💨 Weather updates)
  2. 7-Day Forecast (📅 Plan your week)
  3. Smart Alerts (🔔 Never miss)
  4. Customize Settings (⚙️ Your preferences)
- ⬅️➡️ **Điều khiển:** Swipe hoặc nhấn dots
- ✅ **Kết thúc:** Nhấn "Get Started" → Location Setup

### **Location Setup Screen**
- 📍 **3 tùy chọn:**
  1. GPS Detection (📌 Use My Location)
  2. Search City (🔍 Search manually)
  3. Popular Cities (⭐ Select from list)
- 🔐 **Permission:** Tự động yêu cầu nếu cần
- 💾 **Lưu:** Tọa độ + tên thành phố vào SettingsProvider

### **Settings Screen**
- 🌡️ **Temperature:** °C / °F Toggle
- 💨 **Wind Speed:** km/h / mph Toggle
- 🌙 **Dark Mode:** Light/Dark Toggle
- ⏰ **Time Format:** 12h / 24h Toggle
- 🌐 **Language:** Dropdown (EN/VI)
- 💾 **Tự động save:** Mỗi thay đổi

### **Info Screen**
- ℹ️ **About Section:** Giới thiệu app
- ❓ **FAQ:** 4 câu hỏi thường gặp (expandable)
- 🔒 **Privacy Policy:** Link tới privacy
- ⚖️ **Terms of Service:** Link tới terms
- ⭐ **Rate on Play Store:** Nút rating
- 📤 **Share App:** Nút chia sẻ

---

## 4️⃣ **State Management - Provider Pattern**

### **SettingsProvider**

```dart
class SettingsProvider extends ChangeNotifier {
  // Properties
  String _city = 'Hanoi';
  TemperatureUnit _tempUnit = TemperatureUnit.celsius;
  WindSpeedUnit _windUnit = WindSpeedUnit.kmh;
  AppTheme _theme = AppTheme.light;
  TimeFormat _timeFormat = TimeFormat.format24h;
  String _language = 'en';

  // Getters
  String get city => _city;
  TemperatureUnit get tempUnit => _tempUnit;
  // ... etc

  // Init with SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load all settings from device storage
  }

  // Update methods
  void updateCity(String city) {
    _city = city;
    _prefs.setString('city', city);
    notifyListeners(); // ← UI updates automatically!
  }

  // ... more update methods
}
```

### **Cách Sử Dụng Dalam Widget**

```dart
// Read-only (không rebuild khi thay đổi)
String city = context.read<SettingsProvider>().city;

// Listen (rebuild khi thay đổi)
String city = context.watch<SettingsProvider>().city;

// Update
context.read<SettingsProvider>().updateCity('Ho Chi Minh');
```

---

## 5️⃣ **Dữ Liệu & Enums**

### **settings_model.dart**

```dart
// Enum 1: Temperature Unit
enum TemperatureUnit {
  celsius,
  fahrenheit;
  
  String get label => this == TemperatureUnit.celsius ? '°C' : '°F';
}

// Enum 2: Wind Speed Unit
enum WindSpeedUnit {
  kmh,
  mph;
  
  String get label => this == WindSpeedUnit.kmh ? 'km/h' : 'mph';
}

// Enum 3: App Theme
enum AppTheme {
  light,
  dark;
  
  String get label => this == AppTheme.light ? 'Light' : 'Dark';
}

// Enum 4: Time Format
enum TimeFormat {
  format12h,
  format24h;
  
  String get label => this == TimeFormat.format12h ? '12h' : '24h';
}

// Data Model
class SettingsModel {
  String city;
  double latitude;
  double longitude;
  TemperatureUnit temperatureUnit;
  WindSpeedUnit windSpeedUnit;
  AppTheme appTheme;
  TimeFormat timeFormat;
  String language;
}
```

---

## 6️⃣ **Routing Configuration**

### **app.dart Routes**

```dart
routes: {
  '/': (context) => const SplashScreen(),
  '/onboarding': (context) => const OnboardingScreen(),
  '/location_setup': (context) => const LocationSetupScreen(),
  '/settings': (context) => const SettingsScreen(),
  '/info': (context) => const InfoScreen(),
}
```

### **Navigation Example**

```dart
// Go to Onboarding after Splash
Navigator.pushNamed(context, '/onboarding');

// Replace Stack (back button won't return)
Navigator.pushReplacementNamed(context, '/location_setup');

// Pop to previous
Navigator.pop(context);
```

---

## 7️⃣ **Dependencies (packages used)**

| Package | Phiên Bản | Mục Đích |
|---------|----------|---------|
| flutter | 3.38.4+ | Framework |
| provider | 6.1.5 | State management |
| geolocator | 12.0.0 | GPS location |
| geocoding | 3.0.0 | Reverse geocoding |
| shared_preferences | 2.5.4 | Local storage |
| flutter_dotenv | 5.2.1 | Environment variables |
| url_launcher | 6.4.0 | Open URLs |
| share_plus | 7.2.0 | Share functionality |
| google_fonts | 6.3.3 | Custom fonts |
| lottie | 3.3.2 | Animations |
| shimmer | 3.0.0 | Loading shimmer |

---

## 8️⃣ **Asset Directories (Created)**

```
assets/
├── images/
│   ├── logo/                  # App logo (300x300px)
│   │   └── app_logo.png       # ← Thêm logo ở đây
│   │
│   ├── onboarding/            # 4 slide images
│   │   ├── weather.png        # Slide 1
│   │   ├── forecast.png       # Slide 2
│   │   ├── alerts.png         # Slide 3
│   │   └── settings.png       # Slide 4
│   │
│   ├── weather_icons/         # Weather icons (optional)
│   │   ├── sunny.png
│   │   ├── rainy.png
│   │   └── ...
│   │
│   └── illustrations/         # UI illustrations (optional)
│       └── ...
│
├── lottie/                    # Lottie animations (optional)
│   └── animation.json
│
└── data/                      # Static data files (optional)
    └── cities.json
```

---

## 9️⃣ **Cách Thêm Ảnh Thực**

### **Step 1: Chuẩn Bị Ảnh**
- ✅ Định dạng: PNG hoặc JPG
- ✅ Kích thước: 300x300px (hoặc lớn hơn)
- ✅ Chất lượng: Cao (300 DPI nếu có)

### **Step 2: Đặt Ảnh vào Folders**
```
assets/images/logo/app_logo.png
assets/images/onboarding/weather.png
assets/images/onboarding/forecast.png
assets/images/onboarding/alerts.png
assets/images/onboarding/settings.png
```

### **Step 3: Sửa Code để Dùng Ảnh**

**File:** `lib/screens/OnboardingAndUserPreferencesScreens/splash_screen/splash_animation.dart`

```dart
// ❌ Hiện tại:
Container(
  width: 200,
  height: 200,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.blue.withOpacity(0.2),
  ),
  child: Icon(Icons.cloud, size: 100, color: Colors.blue),
)

// ✅ Sửa thành:
Container(
  width: 200,
  height: 200,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.transparent,
  ),
  child: Image.asset('assets/images/logo/app_logo.png'),
)
```

### **Step 4: Hot Reload**
```bash
flutter run
# Press 'r' to reload
```

---

## 🔟 **Chạy App - Các Tùy Chọn**

### **Option 1: Android/iOS Emulator (Default)**
```bash
flutter run
```

### **Option 2: Web Browser**
```bash
flutter run -d chrome
```
✅ **Nên dùng cách này trước** - không cần Android SDK

### **Option 3: Physical Device**
```bash
flutter run -d <device_id>
```

### **Option 4: Debug Mode**
```bash
flutter run -v  # Verbose output để debug
```

---

## 1️⃣1️⃣ **Troubleshooting**

### **Problem: "flutter not found"**
```bash
# Solution: Add Flutter to PATH
# Windows: Thêm C:\flutter\bin vào PATH environment variable
```

### **Problem: "Gradle Build Failed"**
```bash
# Solution:
flutter clean
flutter pub get
flutter run
```

### **Problem: "Analyzer showing errors"**
```bash
# Solution: Analyzer cache lag - errors sẽ biến mất khi chạy app
# Just run: flutter run
```

### **Problem: "Assets not loading"**
```bash
# Kiểm tra pubspec.yaml assets section có tồn tại không
# flutter pub get
# flutter clean
# flutter run
```

---

## 1️⃣2️⃣ **Useful Commands**

```bash
# Analyzer check
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test

# Build APK (Android)
flutter build apk

# Build AAB (Play Store)
flutter build appbundle

# Build Web
flutter build web

# Clean everything
flutter clean

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade
```

---

## ✨ **Summary**

✅ **5 Màn hình:** Splash → Onboarding → Location → Settings → Info
✅ **State Management:** Provider + SharedPreferences
✅ **GPS Location:** Geolocator + Geocoding integrated
✅ **Persistent Storage:** All settings saved locally
✅ **Ready to Run:** `flutter run -d chrome` hoặc `flutter run`
✅ **Asset Directories:** Tất cả tạo sẵn

**Bạn có thể bắt đầu chạy app ngay!** 🚀
