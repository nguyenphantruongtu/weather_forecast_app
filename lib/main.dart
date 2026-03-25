import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'providers/settings_provider.dart';
import 'providers/news_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/OnboardingAndUserPreferencesScreens/splash_screen/splash_screen.dart';

/// Entry point của ứng dụng
/// main(): hàm chính được gọi khi app khởi động
void main() async {
  // Đảm bảo Flutter bindings được khởi tạo
  // Điều này cần thiết để các plugin native hoạt động đúng cách
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Tải environment variables từ file .env
    // Điều này cho phép lưu trữ API keys trong file .env thay vì hardcode
    await dotenv.load();
  } catch (e) {
    // Nếu .env không tồn tại, in warning nhưng không dừng app
    print('⚠️ Warning: Không thể tải file .env: $e');
  }

  try {
    // Khởi tạo SettingsProvider và tải cài đặt từ SharedPreferences
    final settingsProvider = SettingsProvider();
    await settingsProvider.init();
    // settingsProvider.init(): tải cấu hình đã lưu trước đó
  
    // Load file .env
    await dotenv.load(fileName: '.env');

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

          // Cung cấp NotificationProvider cho toàn bộ app
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    // Nếu có lỗi khởi tạo, hiển thị error screen thay vì trắng xóa
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 20),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    stackTrace.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App Group 6',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SplashScreen(), 
    );
  }
}
