import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'providers/settings_provider.dart';
import 'providers/news_provider.dart';
import 'providers/weather_provider.dart';

/// Entry point của ứng dụn
/// main(): hàm chính được gọi khi app khởi động
void main() async {
  // Đảm bảo Flutter bindings được khởi tạo
  // Điều này cần thiết để các plugin native hoạt động đúng cách
  WidgetsFlutterBinding.ensureInitialized();

  // Tải environment variables từ file .env
  // Điều này cho phép lưu trữ API keys trong file .env thay vì hardcode
  await dotenv.load();

  // Khởi tạo SettingsProvider và tải cài đặt từ SharedPreferences
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();
  // settingsProvider.init(): tải cấu hình đã lưu trước đó

  // Chạy ứng dụng
  runApp(
    MultiProvider(
      // MultiProvider: cung cấp nhiều providers cho toàn bộ app
      // Tất cả widget con có thể truy cập các provider này thông qua context.watch(), context.read(), v.v.
      providers: [
        // Cung cấp SettingsProvider cho toàn bộ app
        // ChangeNotifierProvider.value: sử dụng instance đã tạo sẵn
        ChangeNotifierProvider.value(value: settingsProvider),

        // Cung cấp NewsProvider cho toàn bộ app
        // ChangeNotifierProvider(create: (_) => ...): tạo instance mới
        ChangeNotifierProvider(create: (_) => NewsProvider()),

        // Cung cấp WeatherProvider cho toàn bộ app
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
