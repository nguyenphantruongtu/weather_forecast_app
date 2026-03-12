# 📋 Hệ Thống 4 Màn Hình Onboarding & User Preferences - Hướng Dẫn Tóm Tắt

## ✅ Hoàn Thành Những Gì

Tôi đã tạo hoàn chỉnh 4 màn hình theo yêu cầu:

### **Màn 1: Splash Screen** 🌟
- **Vị trí:** `lib/screens/OnboardingAndUserPreferencesScreens/splash_screen/`
- **File chính:** `splash_screen.dart`
- **Widget con:** `splash_animation.dart`
- **Chức năng:**
  - ✅ Hiển thị logo với animation phóng to (scale) trong 3 giây
  - ✅ Tự động chuyển sang màn Onboarding
  - ✅ Background gradient xanh

### **Màn 2: Onboarding Slides** 📖
- **Vị trí:** `lib/screens/OnboardingAndUserPreferencesScreens/onboarding_screen/`
- **File chính:** `onboarding_screen.dart`
- **Widget con:** `onboarding_page.dart`, `page_indicator.dart`
- **Chức năng:**
  - ✅ 4 slides giới thiệu app
  - ✅ Swipe di chuyển giữa slides
  - ✅ Chấm chỉ thị trang hiện tại (page indicator)
  - ✅ Nút Skip, Back, Next, Start
  - ✅ Animation mượt mà

### **Màn 3: Location Setup** 📍
- **Vị trí:** `lib/screens/OnboardingAndUserPreferencesScreens/location_setup_screen/`
- **File chính:** `location_setup_screen.dart`
- **Widget con:** `location_option_card.dart`, `permission_dialog.dart`
- **Chức năng:**
  - ✅ Option 1: Sử dụng vị trí hiện tại (GPS)
  - ✅ Option 2: Tìm kiếm thành phố
  - ✅ Option 3: Chọn từ danh sách các thành phố nổi tiếng
  - ✅ Dialog xin quyền GPS thân thiện
  - ✅ Chuyển đổi tọa độ thành tên thành phố (reverse geocoding)

### **Màn 4: Settings** ⚙️
- **Vị trí:** `lib/screens/OnboardingAndUserPreferencesScreens/settings_screen/`
- **File chính:** `settings_screen.dart`
- **Widget con:** `setting_tile.dart`, `unit_selector.dart`
- **Chức năng:**
  - ✅ Cài đặt đơn vị nhiệt độ (°C / °F)
  - ✅ Cài đặt đơn vị tốc độ gió (km/h / mph)
  - ✅ Bật/tắt Dark Mode
  - ✅ Cài đặt định dạng giờ (12h / 24h)
  - ✅ Chọn ngôn ngữ (English / Tiếng Việt)
  - ✅ Lưu trữ tự động vào SharedPreferences

### **Màn 5: Info & Help** ℹ️
- **Vị trị:** `lib/screens/OnboardingAndUserPreferencesScreens/info_screen/`
- **File chính:** `info_screen.dart`
- **Widget con:** `faq_item.dart`, `about_section.dart`
- **Chức năng:**
  - ✅ Thông tin app (phiên bản, về ứng dụng)
  - ✅ FAQ (Câu hỏi thường gặp) - mở rộng/gấp
  - ✅ Privacy Policy
  - ✅ Terms of Service
  - ✅ Nút Rating app
  - ✅ Nút Share app

---

## 📁 Cấu Trúc Thư Mục

```
lib/
├── main.dart                           # Entry point
├── app.dart                            # Root widget + routing
│
├── screens/
│   └── OnboardingAndUserPreferencesScreens/
│       ├── splash_screen/
│       │   ├── splash_screen.dart      ✅ Màn 1 - Khởi động
│       │   └── widgets/
│       │       └── splash_animation.dart
│       │
│       ├── onboarding_screen/
│       │   ├── onboarding_screen.dart  ✅ Màn 1 Part 2 - Sliders
│       │   └── widgets/
│       │       ├── onboarding_page.dart
│       │       └── page_indicator.dart
│       │
│       ├── location_setup_screen/
│       │   ├── location_setup_screen.dart ✅ Màn 2 - Vị trí
│       │   └── widgets/
│       │       ├── location_option_card.dart
│       │       └── permission_dialog.dart
│       │
│       ├── settings_screen/
│       │   ├── settings_screen.dart    ✅ Màn 3 - Cài đặt
│       │   └── widgets/
│       │       ├── setting_tile.dart
│       │       └── unit_selector.dart
│       │
│       └── info_screen/
│           ├── info_screen.dart        ✅ Màn 4 - Thông tin
│           └── widgets/
│               ├── faq_item.dart
│               └── about_section.dart
│
├── providers/
│   ├── settings_provider.dart          ✅ Quản lý cài đặt
│   ├── theme_provider.dart             ✅ Quản lý theme
│   ├── news_provider.dart
│   └── notification_provider.dart
│
├── data/
│   └── models/
│       ├── settings_model.dart         ✅ Model cài đặt
│       └── news_article_model.dart
│
└── widgets/
    └── common/
        ├── app_button.dart
        ├── app_text_field.dart
        └── loading_indicator.dart
```

---

## 🔧 Cách Chạy Ứng Dụng

### 1️⃣ **Chuẩn Bị Pod**

```bash
# Vào thư mục dự án
cd c:\Ki_8\Prm393\weather_forecast_app

# Cập nhật packages
flutter pub get
```

### 2️⃣ **Tạo Ảnh Onboarding** (Bắt buộc)

Tạo thư mục `assets/images/onboarding/` và thêm các ảnh:
- `weather.png` (VD: 300x300)
- `forecast.png`
- `alerts.png`
- `settings.png`

**Hoặc dùng placeholder:**
```nếu không có ảnh, app sẽ crash. Hãy tạo ảnh hoặc sử dụng Icon thay vì Image.```

### 3️⃣ **Chạy Ứng Dụng**

```bash
# Chạy trên emulator/device
flutter run

# Hoặc chạy trên web (nếu cần)
flutter run -d chrome
```

### 4️⃣ **Hot Reload Khi Thay Đổi Code**

```bash
# Trong terminal, nhấn 'r' để hot reload
# Hoặc Ctrl+S (VS Code cụ thể)
```

---

## 🎬 **Flow Ứng Dụng**

```
Start App
    ↓
Splash Screen (3 giây)
    ↓
Onboarding Slides (4 slides)
    ↓ Skip hoặc nhấn Start
Location Setup (chọn vị trí)
    ↓
Settings (tuỳ chỉnh cài đặt)
    ↓
Main App (thời tiết)
    ↓ Nhấn menu
Info Screen (về app, FAQ, rating, share)
```

---

## 📱 **Các Plugin Sử Dụng**

| Plugin | Mục Đích |
|--------|---------|
| **provider** | State management (quản lý trạng thái) |
| **geolocator** | Lấy vị trí GPS |
| **geocoding** | Chuyển tọa độ → địa chỉ |
| **shared_preferences** | Lưu dữ liệu local |
| **flutter_dotenv** | Tải biến environment từ .env |
| **url_launcher** | Mở URL/app store |
| **share_plus** | Chia sẻ content |

Tất cả đã được thêm vào `pubspec.yaml` ✅

---

## ⚙️ **Cách Provider Hoạt Động**

### 1️⃣ **Khởi Tạo (main.dart)**
```dart
final settingsProvider = SettingsProvider();
await settingsProvider.init(); // Tải cài đặt cũ
runApp(MultiProvider(providers: [
  ChangeNotifierProvider.value(value: settingsProvider),
]));
```

### 2️⃣ **Sử Dụng (settings_screen.dart)**
```dart
final provider = context.watch<SettingsProvider>();
// Khi user ấn Dark Mode button:
provider.updateTheme(AppTheme.dark);
```

### 3️⃣ **Lưu Trữ (settings_provider.dart)**
```dart
void updateTheme(AppTheme theme) {
  _settings.theme = theme;
  _prefs.setString('theme', 'dark'); // Lưu vào device
  notifyListeners(); // Báo: dữ liệu thay đổi, rebuild UI!
}
```

### 4️⃣ **Rebuild (app.dart)**
```dart
Theme = ThemeProvider.getTheme(settings.theme);
// Theme được cập nhật ngay lập tức!
```

---

## 🐛 **Troubleshooting**

### **Lỗi:** "Image not found"
```
❌ Giải pháp: Tạo ảnh trong assets/images/onboarding/
   hoặc thay Image.asset() bằng Icon()
```

### **Lỗi:** "Permission denied"
```
❌ Giải pháp: Cấp quyền trong AndroidManifest.xml (Android)
   hay Info.plist (iOS)
```

### **Lỗi:** "SharedPreferences not initialized"
```
❌ Giải pháp: Chừa chắc rằng SettingsProvider().init() được gọi
   trong main() trước khi runApp()
```

### **Lỗi:** "Provider not found"
```
❌ Giải pháp: Chừa chắc provider được khai báo trong MultiProvider
```

---

## 📚 **Tài Liệu Chi Tiết**

Hãy đọc file **`FLUTTER_GUIDE_VIETNAMESE.md`** để hiểu chi tiết từng component!

---

## ✨ **Điểm Nổi Bật**

✅ **Sạch & Chuyên Nghiệp:**
- Theo cấu trúc folder rõ ràng
- Tất cả class/function có comment giải thích
- Code theo Dart style guide

✅ **Dễ Tùy Chỉnh:**
- Provider pattern cho phép thêm tính năng dễ dàng
- Widget có thể tái sử dụng (reusable)
- Tất cả text, màu sắc có thể thay đổi

✅ **Hiệu Năng:**
- Sử dụng StatelessWidget khi không cần state
- PageView.builder cho onboarding (không tải tất cả slide cùng lúc)
- Lazy loading

---

## 🎓 **Bước Tiếp Theo (Tùy Chọn)**

1. **Kết nối API thực:** OpenWeatherMap API
2. **Thêm Animation:** Lottie, Framer Motion
3. **Widget chính:** Màn hình hiển thị thời tiết
4. **Local Notifications:** Cảnh báo thời tiết
5. **Unit Tests:** Kiểm tra code

---

**Chúc bạn thành công! 🚀**

Nếu có câu hỏi, hãy đọc **`FLUTTER_GUIDE_VIETNAMESE.md`** hoặc để lại comment trong code!
