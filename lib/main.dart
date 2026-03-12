import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// Import từ branch main
import 'app.dart';
import 'providers/settings_provider.dart';
import 'providers/news_provider.dart';
import 'providers/weather_provider.dart';

// Import từ branch TungNQ
import 'providers/location_provider.dart';
import 'features/location_search_screen/location_search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load file .env
  await dotenv.load(fileName: ".env");

  // Khởi tạo SettingsProvider (từ main)
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        // Giữ tất cả các Provider của cả 2 branch
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()), // Của Tùng
      ],
      child: const MyApp(),
    ),
  );
}

// Lưu ý: Nếu ở branch 'main' đã có class MyApp trong file 'app.dart' 
// thì bạn nên xóa đoạn class MyApp dưới đây và cấu hình trong file app.dart nhé.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App Group 6',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LocationSearchScreen(), // Màn hình của Tùng
    );
  }
}