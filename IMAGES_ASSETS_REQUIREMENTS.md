# 🎨 DANH SÁCH ẢNH & ASSET CẦN THIẾT

## **Trạng Thái Hiện Tại**

✅ **App có thể chạy ngay** - Dùng Icon thay ảnh
⭐ **Ảnh là tùy chọn** - Có thể thêm anytime
🎯 **Hiện tại:** 5 files đang dùng placeholder icons

---

## **1️⃣ MUST-HAVE IMAGES** (Nếu muốn thay Icon)

### **Splash Screen Logo**
| Thuộc tính | Chi tiết |
|-----------|---------|
| **Đường dẫn** | `assets/images/logo/app_logo.png` |
| **Kích thước** | 300×300px (hoặc 512×512px) |
| **Định dạng** | PNG (transparent background) |
| **Nội dung** | Logo ứng dụng - thường là biểu tượng |
| **Hiện tại** | Icon Cloud ☁️ (xanh dương) |
| **Ghi chú** | Sẽ hiển thị với animation scale 3 giây |

---

### **Onboarding Slide Images** (4 ảnh)

#### **Slide 1: Real-time Weather**
| Thuộc tính | Chi tiết |
|-----------|---------|
| **Đường dẫn** | `assets/images/onboarding/weather.png` |
| **Kích thước** | 300×300px |
| **Định dạng** | PNG |
| **Nội dung** | Ảnh liên quan thời tiết (mây, sun, storms) |
| **Hiện tại** | Icon Cloud ☁️ |
| **Gợi ý** | Tìm: "weather illustration" trên unsplash.com |

#### **Slide 2: 7-Day Forecast**
| Thuộc tính | Chi tiết |
|-----------|---------|
| **Đường dẫn** | `assets/images/onboarding/forecast.png` |
| **Kích thước** | 300×300px |
| **Định dạng** | PNG |
| **Nội dung** | Ảnh lịch, bảng biểu, hoặc tuần |
| **Hiện tại** | Icon Calendar 📅 |
| **Gợi ý** | Tìm: "forecast, calendar, schedule" |

#### **Slide 3: Smart Alerts**
| Thuộc tính | Chi tiết |
|-----------|---------|
| **Đường dẫn** | `assets/images/onboarding/alerts.png` |
| **Kích thước** | 300×300px |
| **Định dạng** | PNG |
| **Nội dung** | Ảnh chuông, thông báo, lightning, warning |
| **Hiện tại** | Icon Notification 🔔 |
| **Gợi ý** | Tìm: "notification, alert, bell" |

#### **Slide 4: Customize Settings**
| Thuộc tính | Chi tiết |
|-----------|---------|
| **Đường dẫn** | `assets/images/onboarding/settings.png` |
| **Kích thước** | 300×300px |
| **Định dạng** | PNG |
| **Nội dung** | Ảnh bánh xe, công cụ, cài đặt |
| **Hiện tại** | Icon Settings ⚙️ |
| **Gợi ý** | Tìm: "settings, gear, configuration" |

---

## **2️⃣ OPTIONAL IMAGES** (Cho tương lai)

### **Weather Icons**
```
assets/images/weather_icons/
├── sunny.png              # 120×120px
├── cloudy.png             # 120×120px
├── rainy.png              # 120×120px
├── snowy.png              # 120×120px
└── stormy.png             # 120×120px
```

### **UI Illustrations**
```
assets/images/illustrations/
├── empty_state.png        # 200×200px (khi không có data)
├── error_state.png        # 200×200px (khi có lỗi)
└── loading.png            # 200×200px (đang tải)
```

### **Lottie Animations** (JSON files)
```
assets/lottie/
├── loading_animation.json   # Animation khi tải
├── success_animation.json   # Animation thành công
└── error_animation.json     # Animation lỗi
```

---

## **3️⃣ NGUỒN HÌNH ẢNH MIỄN PHÍ**

### **Website Miễn Phí:**
| Trang web | Loại ảnh | Chất lượng |
|-----------|---------|----------|
| **Unsplash** | Photos | Cao |
| **Pexels** | Photos | Cao |
| **Pixabay** | Photos + Illustrations | Cao |
| **Freepik** | Illustrations + Icons | Rất cao |
| **LottieFiles** | Animations | JSON files |
| **Figma** | Design reference | Thiết kế |

### **Cách tìm:**
1. Vào Unsplash/Pexels
2. Tìm kiếm: "weather illustration", "forecast calendar", v.v.
3. Download PNG version
4. Resize thành 300×300px nếu cần

### **Resize Image (Online Tools):**
- **Photoshop** (Paid)
- **ImageMagick** (Free, command line)
- **Pixlr** (Free, web-based)
- **GIMP** (Free, desktop)

---

## **4️⃣ CÁCH THÊM ẢNH**

### **Step 1: Prepare Image**
```
- Tảo hoặc download ảnh PNG
- Resize thành 300×300px (hoặc lớn hơn)
- Lưu lại với tên phù hợp
```

### **Step 2: Copy to Project**
```
Drag & drop vào folder tương ứng:
- Logo → assets/images/logo/
- Onboarding → assets/images/onboarding/
```

### **Step 3: Update Code**

**File:** `lib/screens/OnboardingAndUserPreferencesScreens/onboarding_screen/widgets/onboarding_page.dart`

```dart
// ❌ HIỆN TẠI:
Widget _buildSlideIcon(String title) {
  return Container(
    width: 200,
    height: 200,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _getIconColor(title),
    ),
    child: Icon(_getIconForTitle(title), size: 100, color: Colors.white),
  );
}

// ✅ SỬA THÀNH:
Widget _buildSlideIcon(String title) {
  final Map<String, String> images = {
    'Real-time Weather': 'assets/images/onboarding/weather.png',
    '7-Day Forecast': 'assets/images/onboarding/forecast.png',
    'Smart Alerts': 'assets/images/onboarding/alerts.png',
    'Customize Settings': 'assets/images/onboarding/settings.png',
  };
  
  return Container(
    width: 200,
    height: 200,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.grey[100],
    ),
    child: ClipOval(
      child: Image.asset(
        images[title] ?? 'assets/images/logo/app_logo.png',
        fit: BoxFit.cover,
      ),
    ),
  );
}
```

**File:** `lib/screens/OnboardingAndUserPreferencesScreens/splash_screen/splash_animation.dart`

```dart
// ❌ HIỆN TẠI:
Container(
  width: 200,
  height: 200,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.blue.withOpacity(0.2),
  ),
  child: Icon(Icons.cloud, size: 100, color: Colors.blue),
)

// ✅ SỬA THÀNH:
Container(
  width: 200,
  height: 200,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.transparent,
  ),
  child: ClipOval(
    child: Image.asset(
      'assets/images/logo/app_logo.png',
      fit: BoxFit.cover,
    ),
  ),
)
```

### **Step 4: Hot Reload**
```bash
flutter run
# Nhấn 'r' để reload (hoặc Ctrl+S)
```

---

## **5️⃣ KIỂM TRA ĐẢ TẠO ĐÚNG KHÔNG**

```bash
# Liệt kê files trong assets/
ls assets/images/logo/
ls assets/images/onboarding/

# Output sẽ thu được:
# assets/images/logo/app_logo.png ✅
# assets/images/onboarding/weather.png ✅
# ...
```

---

## **6️⃣ TROUBLESHOOTING**

### **Problem: App crash sau khi thêm ảnh**
```
⚠️ Nguyên nhân: File path sai hoặc image file corrupt
✅ Giải pháp:
  1. Kiểm tra file name (case-sensitive!)
  2. Kiểm tra file format (PNG hoặc JPG)
  3. Kiểm tra file size (< 10MB)
  4. flutter clean && flutter pub get
```

### **Problem: Ảnh không hiển thị**
```
⚠️ Nguyên nhân: pubspec.yaml assets chưa update
✅ Giải pháp:
  1. Kiểm tra pubspec.yaml có section "assets:"
  2. Kiểm tra indentation (phải align)
  3. flutter pub get
  4. flutter clean && flutter run
```

### **Problem: Image quality xấu**
```
⚠️ Nguyên nhân: ảnh resolution thấp
✅ Giải pháp:
  1. Download ảnh Hi-Res (2K+)
  2. Resize bằng Photoshop/GIMP
  3. Export PNG quality cao
```

---

## **7️⃣ CHECKLIST**

```
☐ Splash Logo:
  ☐ File: assets/images/logo/app_logo.png
  ☐ Size: 300×300px
  ☐ Format: PNG
  ☐ Code updated: splash_animation.dart

☐ Onboarding Images (4):
  ☐ weather.png → assets/images/onboarding/
  ☐ forecast.png → assets/images/onboarding/
  ☐ alerts.png → assets/images/onboarding/
  ☐ settings.png → assets/images/onboarding/
  ☐ Code updated: onboarding_page.dart

☐ (Optional) Weather Icons:
  ☐ sunny.png, cloudy.png, rainy.png, etc.
  ☐ Size: 120×120px each

☐ (Optional) Illustrations:
  ☐ empty_state.png, error_state.png, loading.png
  ☐ Size: 200×200px each

☐ (Optional) Lottie Animations:
  ☐ JSON files từ LottieFiles

☐ Final Check:
  ☐ flutter pub get
  ☐ flutter clean
  ☐ flutter run ✅
```

---

## **8️⃣ KÍCH THƯỚC RECOMMEND**

| Asset | Resolution | Size (MB) | Format |
|-------|-----------|----------|--------|
| Logo | 300×300px | 0.1-0.3 | PNG |
| Onboarding | 300×300px | 0.1-0.3 | PNG |
| Weather Icons | 120×120px | 0.05-0.1 | PNG |
| Illustrations | 200×200px | 0.1-0.2 | PNG |
| Lottie | N/A | 0.05-0.2 | JSON |

**Total: ~1.5-2 MB nên ok**

---

## **QUICK SUMMARY**

✅ **Currently:** App runs with placeholder Icons
✅ **To upgrade:** Just add 4-5 PNG files + minor code changes
✅ **Time needed:** 15-30 minutes (download + resize + update code)
✅ **Difficulty:** Easy - no complex setup needed

**App can ship with Icons, or add images later!** 🎉

